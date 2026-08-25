from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
import os

router = APIRouter(prefix="/api/v1/map", tags=["Map"])

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


@router.get("/")
async def get_map_places(user_id: str = "default_user"):
  try:
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