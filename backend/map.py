from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from typing import Optional

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

router = APIRouter(prefix="/api/v1/map", tags=["Map"])

SUPABASE_URL = os.environ.get("SUPABASE_URL") or None
SUPABASE_KEY = os.environ.get("SUPABASE_KEY") or None
supabase: Optional[Client] = (
    create_client(SUPABASE_URL, SUPABASE_KEY)
    if SUPABASE_URL and SUPABASE_KEY
    else None
)


@router.get("/")
async def get_map_places(user_id: str = "default_user"):
  try:
    if not supabase:
      return {"status": "success", "places": []}

    response = (
        supabase.table("map_places")
        .select("*")
        .eq("user_id", user_id)
        .order("created_at", desc=True)
        .execute()
    )
    return {"status": "success", "places": response.data}
  except Exception as e:
    raise HTTPException(
        status_code=500, detail=f"장소 목록 조회 실패: {str(e)}"
    )
