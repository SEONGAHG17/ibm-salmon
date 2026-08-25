import os
from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/api/v1/calendar", tags=["Calendar"])

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


@router.get("/")
async def get_calendar_events(user_id: str = "default_user"):
    try:
        response = (
            supabase.table("calendar_events")
            .select("*")
            .eq("user_id", user_id)
            .order("event_date", desc=False)
            .execute()
        )
        return {"status": "success", "events": response.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"일정 목록 조회 실패: {str(e)}")
    
