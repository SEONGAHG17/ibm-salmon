import time
import os
import json
import asyncio
from dotenv import load_dotenv
from typing import Any, Optional

load_dotenv()

from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel, Field
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
from ibm_watsonx_ai.foundation_models import Embeddings, ModelInference
from ibm_watsonx_ai.metanames import GenChatParamsMetaNames as ChatParams

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
qdrant_client = QdrantClient(url=QDRANT_URL, api_key=QDRANT_API_KEY) if QDRANT_URL else None

# IBM watsonx 인증 정보 및 임베딩 설정
watsonx_api_key = os.environ.get("WATSONX_API_KEY")
watsonx_url = os.environ.get("WATSONX_URL", "https://us-south.ml.cloud.ibm.com")
watsonx_project_id = os.environ.get("WATSONX_PROJECT_ID")
embedding_model_id = os.environ.get("WATSONX_EMBEDDING_MODEL_ID", "intfloat/multilingual-e5-large")
watsonx_chat_model_id = os.environ.get("WATSONX_CHAT_MODEL_ID", "ibm/granite-3-8b-instruct")

credentials = Credentials(url=watsonx_url, api_key=watsonx_api_key) if watsonx_api_key else None


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


class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    user_id: str = "default_user"
    history: list[ChatMessage] = Field(default_factory=list)
    limit: int = 12


class ChatCitation(BaseModel):
    id: Optional[Any] = None
    category: Optional[str] = None
    summary: Optional[str] = None
    action_type: Optional[str] = None
    action_data: Optional[str] = None
    created_at: Optional[str] = None


class ChatResponse(BaseModel):
    status: str
    reply: str
    provider: str
    model: str
    citations: list[ChatCitation] = Field(default_factory=list)


def _watsonx_ready() -> bool:
    return bool(credentials and watsonx_project_id)


def _select_history_items(user_id: str, limit: int) -> list[dict[str, Any]]:
    safe_limit = min(max(limit, 1), 30)
    response = (
        supabase.table("analyzed_items")
        .select("id, image_url, category, summary, action_type, action_data, created_at")
        .eq("user_id", user_id)
        .order("created_at", desc=True)
        .limit(safe_limit)
        .execute()
    )
    return response.data or []


def _pick_relevant_items(question: str, items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    normalized_question = question.lower()
    category_keywords = ["맛집", "공모전", "장학금", "기프티콘", "여행", "기타"]
    action_keywords = {
        "일정": ["일정", "캘린더", "마감", "날짜"],
        "지도": ["지도", "장소", "주소", "위치", "맛집"],
        "링크": ["링크", "사이트", "url", "바로가기"],
    }

    matched_items: list[dict[str, Any]] = []
    for item in items:
        searchable_text = " ".join(
            str(item.get(key, "") or "")
            for key in ["category", "summary", "action_type", "action_data"]
        ).lower()

        category_hit = any(keyword in normalized_question and keyword in searchable_text for keyword in category_keywords)
        action_hit = any(
            any(keyword in normalized_question for keyword in keywords) and action_name in searchable_text
            for action_name, keywords in action_keywords.items()
        )
        plain_hit = any(token and token in searchable_text for token in normalized_question.split())

        if category_hit or action_hit or plain_hit:
            matched_items.append(item)

    return matched_items[:6] if matched_items else items[:5]


def _format_history_context(items: list[dict[str, Any]]) -> str:
    if not items:
        return "저장된 스크린샷 분석 결과가 없습니다."

    context_rows = []
    for idx, item in enumerate(items, start=1):
        context_rows.append(
            "\n".join([
                f"[{idx}] id: {item.get('id', '')}",
                f"category: {item.get('category', '')}",
                f"summary: {item.get('summary', '')}",
                f"action_type: {item.get('action_type', '')}",
                f"action_data: {item.get('action_data', '')}",
                f"created_at: {item.get('created_at', '')}",
            ])
        )
    return "\n\n".join(context_rows)


def _clean_chat_history(history: list[ChatMessage]) -> list[dict[str, str]]:
    cleaned_history: list[dict[str, str]] = []
    for message in history[-8:]:
        role = message.role if message.role in {"user", "assistant"} else "user"
        content = message.content.strip()
        if content:
            cleaned_history.append({"role": role, "content": content[:1000]})
    return cleaned_history


def _build_chat_messages(
    question: str,
    items: list[dict[str, Any]],
    history: list[ChatMessage],
) -> list[dict[str, str]]:
    system_prompt = """
너는 T.Salmon 앱의 Watsonx 챗봇이다.
사용자가 저장한 스마트폰 스크린샷 분석 결과를 바탕으로만 답한다.
분석 결과에 없는 정보는 추측하지 말고, 없다고 말한 뒤 어떤 스크린샷을 추가로 업로드하면 좋을지 짧게 안내한다.
카테고리, 요약, 액션 타입, 주소/링크/날짜 정보를 우선 사용한다.
일정은 날짜와 제목 중심으로, 지도 항목은 장소/주소 중심으로, 링크 항목은 바로가기 정보 중심으로 정리한다.
답변은 한국어로, 해커톤 데모에서 바로 보여주기 좋게 간결하고 자신 있게 작성한다.
""".strip()

    context = _format_history_context(items)
    messages = [{"role": "system", "content": f"{system_prompt}\n\n저장된 분석 결과:\n{context}"}]
    messages.extend(_clean_chat_history(history))
    messages.append({"role": "user", "content": question})
    return messages


def _extract_watsonx_reply(response: dict[str, Any]) -> str:
    try:
        return response["choices"][0]["message"]["content"].strip()
    except (KeyError, IndexError, TypeError, AttributeError):
        pass

    try:
        return response["results"][0]["generated_text"].strip()
    except (KeyError, IndexError, TypeError, AttributeError):
        pass

    return "답변을 생성했지만 응답 형식을 해석하지 못했습니다. 잠시 후 다시 질문해주세요."


async def _ask_watsonx(messages: list[dict[str, str]]) -> str:
    if not _watsonx_ready():
        raise RuntimeError("watsonx 환경 변수가 설정되지 않았습니다.")

    chat_model = ModelInference(
        model_id=watsonx_chat_model_id,
        credentials=credentials,
        project_id=watsonx_project_id,
    )
    params = {
        ChatParams.TEMPERATURE: 0.2,
        ChatParams.MAX_TOKENS: 700,
        ChatParams.TOP_P: 0.9,
        ChatParams.TIME_LIMIT: 10000,
    }
    response = await asyncio.to_thread(chat_model.chat, messages=messages, params=params)
    return _extract_watsonx_reply(response)


def _fallback_chat_reply(question: str, items: list[dict[str, Any]]) -> str:
    if not items:
        return "아직 저장된 스크린샷 분석 결과가 없습니다. 스크린샷을 먼저 업로드하면 카테고리, 일정, 장소, 링크 정보를 바탕으로 답변할 수 있어요."

    relevant_items = _pick_relevant_items(question, items)
    lines = ["Watsonx 연결 전에도 확인할 수 있도록 저장된 분석 결과 기준으로 정리했어요."]
    for item in relevant_items[:4]:
        category = item.get("category") or "미분류"
        summary = item.get("summary") or "요약 없음"
        action_type = item.get("action_type") or "해당없음"
        action_data = item.get("action_data") or ""
        detail = f" - {action_data}" if action_data else ""
        lines.append(f"- [{category}] {summary} ({action_type}){detail}")
    return "\n".join(lines)


def _to_citations(items: list[dict[str, Any]]) -> list[ChatCitation]:
    return [
        ChatCitation(
            id=item.get("id"),
            category=item.get("category"),
            summary=item.get("summary"),
            action_type=item.get("action_type"),
            action_data=item.get("action_data"),
            created_at=item.get("created_at"),
        )
        for item in items[:5]
    ]


@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat_with_watsonx(request: ChatRequest):
    question = request.message.strip()
    if not question:
        raise HTTPException(status_code=400, detail="질문을 입력해주세요.")

    try:
        items = _select_history_items(request.user_id, request.limit)
        relevant_items = _pick_relevant_items(question, items)
        messages = _build_chat_messages(question, relevant_items, request.history)

        try:
            reply = await _ask_watsonx(messages)
            provider = "watsonx"
        except Exception as watson_error:
            print(f"⚠️ [Watsonx Chat Fallback] {str(watson_error)}")
            reply = _fallback_chat_reply(question, relevant_items)
            provider = "local_fallback"

        return ChatResponse(
            status="success",
            reply=reply,
            provider=provider,
            model=watsonx_chat_model_id,
            citations=_to_citations(relevant_items),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"챗봇 응답 실패: {str(e)}")


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

        # watsonx 임베딩 및 Qdrant 저장은 검색 품질을 높이는 보조 단계다.
        # 설정이 빠져도 이미지 분석 결과 저장은 성공하도록 분리한다.
        if _watsonx_ready() and qdrant_client:
            try:
                text_to_embed = f"[{saved_category}] {saved_summary} | 정보: {saved_action_data}"
                embed_engine = Embeddings(
                    model_id=embedding_model_id,
                    credentials=credentials,
                    project_id=watsonx_project_id
                )
                vector = embed_engine.embed_documents([text_to_embed])[0]

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
            except Exception as embed_error:
                print(f"⚠️ [Watsonx Embedding Skip] {str(embed_error)}")

        return {
            "status": "success",
            "image_url": image_url,
            "analysis": analysis_data
        }

    except Exception as e:
        print(f"\n❌ [ERROR] 파이프라인 에러 발생: {str(e)}\n")
        raise HTTPException(status_code=500, detail=f"파이프라인 에러: {str(e)}")

