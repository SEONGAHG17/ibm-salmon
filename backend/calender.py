import os
from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
from dotenv import load_dotenv
from typing import Optional

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

router = APIRouter(prefix="/api/v1/calendar", tags=["Calendar"])

SUPABASE_URL = os.environ.get("SUPABASE_URL") or None
SUPABASE_KEY = os.environ.get("SUPABASE_KEY") or None
supabase: Optional[Client] = (
    create_client(SUPABASE_URL, SUPABASE_KEY)
    if SUPABASE_URL and SUPABASE_KEY
    else None
)


@router.get("/")
async def get_calendar_events(user_id: str = "default_user"):
    try:
        if not supabase:
            return {"status": "success", "events": []}

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
    
