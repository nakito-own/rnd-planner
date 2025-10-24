from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import re
import json

router = APIRouter()

class GeoJsonDecodeRequest(BaseModel):
    geojson: Dict[str, Any]

class GeoJsonDecodeResponse(BaseModel):
    tickets: List[str]

def extract_tickets_from_json(data: Any, tickets: set) -> None:
    """
    Рекурсивно извлекает тикеты из JSON структуры.
    Ищет строки в формате 'PREFIX-числа', например 'SDGLOGISTICS-482874'
    """
    if isinstance(data, dict):
        for value in data.values():
            extract_tickets_from_json(value, tickets)
    elif isinstance(data, list):
        for item in data:
            extract_tickets_from_json(item, tickets)
    elif isinstance(data, str):
        # Ищем паттерн: буквы-дефис-цифры (например, SDGLOGISTICS-482874)
        pattern = r'([A-Z]{2,}-?\d+)'
        matches = re.findall(pattern, data, re.IGNORECASE)
        for match in matches:
            tickets.add(match)

@router.post("/decode", response_model=GeoJsonDecodeResponse)
async def decode_geojson(request: GeoJsonDecodeRequest):
    """
    Декодирует GeoJSON и извлекает тикеты в формате 'PREFIX-числа'
    Возвращает список тикетов в формате 'st.yandex-team.ru/TICKET'
    """
    try:
        tickets = set()
        extract_tickets_from_json(request.geojson, tickets)
        
        # Формируем список тикетов в формате st.yandex-team.ru/TICKET
        ticket_urls = [f"st.yandex-team.ru/{ticket}" for ticket in sorted(tickets)]
        
        return GeoJsonDecodeResponse(tickets=ticket_urls)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Ошибка при декодировании GeoJSON: {str(e)}")

