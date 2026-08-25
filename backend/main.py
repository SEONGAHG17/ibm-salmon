import time
import os
import json
from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
import google.generativeai as genai
from supabase import create_client, Client
from qdrant_client import QdrantClient
from qdrant_client.http import models

# 라우터 임포트
from history import router as history_router
from calender import router as calendar_router
from map import router as map_router
from scheduler import start_scheduler  # 스케줄러 임포트

# IBM watsonx 임베딩 라이브러리 임포트
from ibm_watsonx_ai import Credentials
from ibm_watsonx_ai.foundation_models import Embeddings

app = FastAPI(title="T.Salmon API", version="1.0")

# 라우터 등록
app.include_router(history_router)
app.include_router(calendar_router)
app.include_router(map_router)

# 1. 환경 변수 및 클라이언트 초기화
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

genai.configure(api_key=os.environ.get("GEMINI_API_KEY"))
model = genai.GenerativeModel('gemini-3.7-flash')

QDRANT_URL = os.environ.get("QDRANT_URL")
QDRANT_API_KEY = os.environ.get("QDRANT_API_KEY")
qdrant_client = QdrantClient(url=QDRANT_URL, api_key=QDRANT_API_KEY)

# IBM watsonx 인증 정보 및 임베딩 설정
watsonx_api_key = os.environ.get("WATSONX_API_KEY")
watsonx_url = os.environ.get("WATSONX_URL", "https://us-south.ml.cloud.ibm.com")
watsonx_project_id = os.environ.get("WATSONX_PROJECT_ID")
embedding_model_id = os.environ.get("WATSONX_EMBEDDING_MODEL_ID", "intfloat/multilingual-e5-large")

credentials = Credentials(url=watsonx_url, api_key=watsonx_api_key)


# 서버 시작 시 스케줄러 자동 구동
@app.on_event("startup")
async def on_startup():
    start_scheduler()


# FCM 디바이스 토큰 등록 엔드포인트
class DeviceTokenRequest(BaseModel):
    user_id: str = "default_user"
    fcm_token: str


@app.post("/api/v1/devices/token")
async def register_device_token(request: DeviceTokenRequest):
    try:
        supabase.table("user_devices").upsert({
            "user_id": request.user_id,
            "fcm_token": request.fcm_token
        }).execute()
        return {"status": "success", "message": "Device token registered"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"토큰 등록 실패: {str(e)}")


class AnalysisResponse(BaseModel):
    status: str
    image_url: str
    analysis: dict


@app.post("/api/v1/analyze", response_model=AnalysisResponse)
async def process_and_analyze_image(file: UploadFile = File(...)):
    try:
        file_bytes = await file.read()
        filename = f"screenshot_{int(time.time())}_{file.filename}"
        
        # MIME Type 자동 보정
        content_type = file.content_type
        if not content_type or content_type == "application/octet-stream":
            if file.filename and file.filename.lower().endswith(".png"):
                content_type = "image/png"
            else:
                content_type = "image/jpeg"
        
        supabase.storage.from_("screenshots").upload(
            path=filename,
            file=file_bytes,
            file_options={"content-type": content_type}
        )
        
        image_url = supabase.storage.from_("screenshots").get_public_url(filename)
        
        prompt = """
        너는 스마트폰 스크린샷을 정밀 분석하는 비서야.
        이미지 내의 텍스트(OCR), 상호명, 도로명 주소, 날짜, 상품명, UI 문구를 최대한 꼼꼼하게 읽어내서 요약해.
        아래 형식의 JSON으로만 정확하게 응답해. 백틱(```)이나 마크다운 외 다른 말은 절대 금지.
        {
        "category": "맛집 또는 공모전 또는 장학금 또는 기프티콘 또는 여행 또는 기타 중 택1", 
        "summary": "핵심 내용 및 상호명, 주요 정보 한 줄 요약", 
        "action_type": "지도매핑 또는 일정등록 또는 링크 이동 또는 해당없음 중 택1", 
        "action_data": "대표 참고할 링크나 주소, 날짜 정보 (없으면 빈 문자열)",
        "schedules": [
            {"title": "일정 이름", "date": "YYYY-MM-DD"}
        ],
        "places": [
            {"place_name": "장소명 또는 상호명", "address": "도로명 주소 또는 위치 설명"}
        ]
        }
        """
        
        image_part = {
            "mime_type": content_type,
            "data": file_bytes
        }
        
        response = model.generate_content([prompt, image_part])
        response_text = response.text.strip()
        
        if response_text.startswith("```"):
            response_text = response_text.split("```")[1]
            if response_text.startswith("json"):
                response_text = response_text[4:]
        response_text = response_text.strip()
        
        analysis_data = json.loads(response_text)
        
        category = analysis_data.get("category")
        summary = analysis_data.get("summary")
        action_type = analysis_data.get("action_type")
        places = analysis_data.get("places", [])
        
        if action_type == "지도매핑" and places:
            first_place = places[0]
            action_data = first_place.get("address") or first_place.get("place_name") or analysis_data.get("action_data", "")
        else:
            action_data = analysis_data.get("action_data", "")

        db_data = {
            "user_id": "default_user",
            "image_url": image_url,
            "category": category,
            "summary": summary,
            "action_type": action_type,
            "action_data": action_data
        }
        db_result = supabase.table("analyzed_items").insert(db_data).execute()
        
        inserted_row = db_result.data[0]
        item_id = inserted_row["id"]
        saved_category = inserted_row["category"]
        saved_summary = inserted_row["summary"]
        saved_action_data = inserted_row["action_data"]

        # 캘린더 후처리
        schedules = analysis_data.get("schedules", [])
        if action_type == "일정등록" and schedules:
            for sch in schedules:
                calendar_event_data = {
                    "user_id": "default_user",
                    "item_id": item_id,
                    "title": sch.get("title"),
                    "event_date": sch.get("date"),
                    "image_url": image_url
                }
                supabase.table("calendar_events").insert(calendar_event_data).execute()

        # 지도 후처리
        if action_type == "지도매핑" and places:
            for pl in places:
                map_place_data = {
                    "user_id": "default_user",
                    "item_id": item_id,
                    "place_name": pl.get("place_name"),
                    "address": pl.get("address"),
                    "image_url": image_url
                }
                supabase.table("map_places").insert(map_place_data).execute()

        # watsonx 임베딩
        text_to_embed = f"[{saved_category}] {saved_summary} | 정보: {saved_action_data}"
        embed_engine = Embeddings(
            model_id=embedding_model_id,
            credentials=credentials,
            project_id=watsonx_project_id
        )
        vector = embed_engine.embed_documents([text_to_embed])[0]
        
        # Qdrant 업서트
        qdrant_client.upsert(
            collection_name="screenshots",
            points=[
                models.PointStruct(
                    id=item_id,
                    vector=vector,
                    payload={
                        "user_id": "default_user",
                        "image_url": image_url,
                        "category": saved_category,
                        "summary": saved_summary,
                        "action_data": saved_action_data
                    }
                )
            ]
        )
        
        return {
            "status": "success",
            "image_url": image_url,
            "analysis": analysis_data
        }

    except Exception as e:
        print(f"\n❌ [ERROR] 파이프라인 에러 발생: {str(e)}\n")
        raise HTTPException(status_code=500, detail=f"파이프라인 에러: {str(e)}")

