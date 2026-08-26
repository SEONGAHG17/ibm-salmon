from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from typing import Optional

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

router = APIRouter(prefix="/api/v1/history", tags=["History"])

SUPABASE_URL = os.environ.get("SUPABASE_URL") or None
SUPABASE_KEY = os.environ.get("SUPABASE_KEY") or None
supabase: Optional[Client] = (
    create_client(SUPABASE_URL, SUPABASE_KEY)
    if SUPABASE_URL and SUPABASE_KEY
    else None
)


@router.get("/")
async def get_dashboard_history(user_id: str = "default_user", limit: int = 50):
    try:
        if not supabase:
            return {"status": "success", "history": []}

        # action_data 컬럼 반드시 포함
        response = (
            supabase.table("analyzed_items")
            .select("id, image_url, category, summary, action_type, action_data, created_at")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(limit)
            .execute()
        )
        return {"status": "success", "history": response.data}
    
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"히스토리 조회 실패: {str(e)}"
        )

