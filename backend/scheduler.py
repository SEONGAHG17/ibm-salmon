import os
from datetime import datetime, timedelta
import firebase_admin
from firebase_admin import credentials, messaging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

# Supabase 클라이언트 초기화
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Firebase Admin SDK 절대 경로 기반 초기화
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH", os.path.join(BASE_DIR, "serviceAccountKey.json"))

if not firebase_admin._apps:
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("✅ [Firebase Admin] 초기화 성공")
    else:
        print(f"⚠️ [Firebase Admin] 키 파일을 찾을 수 없습니다: {cred_path}")

scheduler = AsyncIOScheduler()

async def send_fcm_notification(fcm_token: str, title: str, body: str):
    """FCM 단일 기기 푸시 발송 함수"""
    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            token=fcm_token,
        )
        response = messaging.send(message)
        print(f"🔔 [FCM 푸시 전송 완료] ID: {response}")
    except Exception as e:
        print(f"❌ [FCM 푸시 전송 실패]: {str(e)}")

# 작업 1: 당일 스크린샷 정리 브리핑 (매일 21:00)
async def check_daily_captures():
    today_str = datetime.now().strftime("%Y-%m-%d")
    print(f"⏰ [스케줄러 실행] 당일 스크린샷 정리 체크 ({today_str})")
    
    response = (
        supabase.table("analyzed_items")
        .select("id, summary")
        .gte("created_at", f"{today_str}T00:00:00")
        .execute()
    )
    items = response.data or []
    count = len(items)

    if count > 0:
        devices = supabase.table("user_devices").select("fcm_token").eq("user_id", "default_user").execute()
        for dev in devices.data:
            await send_fcm_notification(
                fcm_token=dev["fcm_token"],
                title="📸 오늘의 스크린샷 브리핑",
                body=f"오늘 총 {count}개의 스크린샷이 정리되었습니다. 앱에서 확인해보세요!"
            )

# 작업 2: 캘린더 D-1 마감/일정 알림 (매일 09:00)
async def check_calendar_d_minus_one():
    tomorrow_str = (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")
    print(f"⏰ [스케줄러 실행] 캘린더 D-1 마감 일정 체크 ({tomorrow_str})")
    
    response = (
        supabase.table("calendar_events")
        .select("title")
        .eq("event_date", tomorrow_str)
        .execute()
    )
    events = response.data or []

    if events:
        devices = supabase.table("user_devices").select("fcm_token").eq("user_id", "default_user").execute()
        for event in events:
            event_title = event.get("title", "예정된 일정")
            for dev in devices.data:
                await send_fcm_notification(
                    fcm_token=dev["fcm_token"],
                    title="⏰ [D-1] 내일 마감/예정된 일정 알림",
                    body=f"내일 일정: '{event_title}'"
                )

# 테스트용 수동 트리거 함수
async def trigger_daily_captures_test():
    await check_daily_captures()

async def trigger_calendar_d1_test():
    await check_calendar_d_minus_one()

def start_scheduler():
    scheduler.add_job(check_daily_captures, "cron", hour=21, minute=0)
    scheduler.add_job(check_calendar_d_minus_one, "cron", hour=9, minute=0)
    scheduler.start()
    print("🚀 [APScheduler] 백그라운드 스케줄러 시작됨")

