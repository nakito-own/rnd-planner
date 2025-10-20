from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models.schemas import Shift, ShiftCreate, ShiftUpdate, ShiftWithTasks, ShiftWithEnrichedTasks, EnrichedTaskForShift
from app.crud import shift_crud

router = APIRouter()

@router.get("/test", response_model=dict)
async def test_endpoint():
    """Тестовая ручка для проверки работы API"""
    return {"message": "API is working", "status": "ok"}

@router.get("/", response_model=List[Shift])
async def get_shifts(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """Получить список всех смен"""
    return shift_crud.get_shifts(db, skip=skip, limit=limit)

@router.get("/{shift_id}", response_model=ShiftWithEnrichedTasks)
async def get_shift(shift_id: int, db: Session = Depends(get_db)):
    """Получить смену по ID с задачами и дополнительной информацией"""
    shift = shift_crud.get_shift_with_tasks(db, shift_id)
    if not shift:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    
    # Обогащаем данные задач
    enriched_tasks = []
    for task in shift.tasks:
        enriched_task_data = shift_crud.enrich_task_data(task)
        enriched_task = EnrichedTaskForShift(**enriched_task_data)
        enriched_tasks.append(enriched_task)
    
    # Создаем обогащенную смену
    shift_data = {
        'id': shift.id,
        'date': shift.date,
        'time_start': shift.time_start,
        'time_end': shift.time_end,
        'edited_at': shift.edited_at,
        'created_at': shift.created_at,
        'updated_at': shift.updated_at,
        'tasks': enriched_tasks
    }
    
    return ShiftWithEnrichedTasks(**shift_data)

@router.post("/", response_model=Shift)
async def create_shift(shift: ShiftCreate, db: Session = Depends(get_db)):
    """Создать новую смену"""
    return shift_crud.create_shift(db, shift)

@router.put("/{shift_id}", response_model=Shift)
async def update_shift(
    shift_id: int, 
    shift_update: ShiftUpdate, 
    db: Session = Depends(get_db)
):
    """Обновить смену"""
    shift = shift_crud.update_shift(db, shift_id, shift_update)
    if not shift:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    return shift

@router.delete("/{shift_id}")
async def delete_shift(shift_id: int, db: Session = Depends(get_db)):
    """Удалить смену"""
    success = shift_crud.delete_shift(db, shift_id)
    if not success:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    return {"message": "Смена успешно удалена"}

@router.get("/date/{date}", response_model=List[ShiftWithEnrichedTasks])
async def get_shifts_by_date(date: datetime, db: Session = Depends(get_db)):
    """Получить смены по конкретной дате с полной информацией о задачах"""
    try:
        print(f"Received date: {date}")
        shifts = shift_crud.get_shifts_by_date(db, date)
        print(f"Found {len(shifts)} shifts")
        
        # Обогащаем каждую смену данными о задачах
        enriched_shifts = []
        for shift in shifts:
            # Получаем смену с задачами
            shift_with_tasks = shift_crud.get_shift_with_tasks(db, shift.id)
            if shift_with_tasks:
                # Обогащаем данные задач
                enriched_tasks = []
                for task in shift_with_tasks.tasks:
                    enriched_task_data = shift_crud.enrich_task_data(task)
                    enriched_task = EnrichedTaskForShift(**enriched_task_data)
                    enriched_tasks.append(enriched_task)
                
                # Создаем обогащенную смену
                shift_data = {
                    'id': shift_with_tasks.id,
                    'date': shift_with_tasks.date,
                    'time_start': shift_with_tasks.time_start,
                    'time_end': shift_with_tasks.time_end,
                    'edited_at': shift_with_tasks.edited_at,
                    'created_at': shift_with_tasks.created_at,
                    'updated_at': shift_with_tasks.updated_at,
                    'tasks': enriched_tasks
                }
                
                enriched_shift = ShiftWithEnrichedTasks(**shift_data)
                enriched_shifts.append(enriched_shift)
        
        print(f"Returning {len(enriched_shifts)} enriched shifts")
        return enriched_shifts
    except Exception as e:
        print(f"Error in get_shifts_by_date: {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@router.get("/date-range/", response_model=List[Shift])
async def get_shifts_by_date_range(
    start_date: datetime,
    end_date: datetime,
    db: Session = Depends(get_db)
):
    """Получить смены в заданном диапазоне дат"""
    return shift_crud.get_shifts_by_date_range(db, start_date, end_date)

@router.get("/active/", response_model=List[Shift])
async def get_active_shifts(db: Session = Depends(get_db)):
    """Получить активные смены (текущее время между time_start и time_end)"""
    return shift_crud.get_active_shifts(db)
