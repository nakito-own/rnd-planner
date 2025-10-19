from fastapi import APIRouter, HTTPException
from typing import List
from app.models.schemas import Shift, ShiftCreate, ShiftUpdate
from datetime import datetime

router = APIRouter()

shifts_db = []
shift_id_counter = 1

@router.get("/", response_model=List[Shift])
async def get_shifts():
    return shifts_db

@router.get("/{shift_id}", response_model=Shift)
async def get_shift(shift_id: int):
    shift = next((s for s in shifts_db if s.id == shift_id), None)
    if not shift:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    return shift

@router.post("/", response_model=Shift)
async def create_shift(shift: ShiftCreate):
    global shift_id_counter
    
    new_shift = Shift(
        id=shift_id_counter,
        name=shift.name,
        start_time=shift.start_time,
        end_time=shift.end_time,
        status=shift.status,
        description=shift.description,
        crew_id=shift.crew_id,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )
    
    shifts_db.append(new_shift)
    shift_id_counter += 1
    
    return new_shift

@router.put("/{shift_id}", response_model=Shift)
async def update_shift(shift_id: int, shift_update: ShiftUpdate):
    shift = next((s for s in shifts_db if s.id == shift_id), None)
    if not shift:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    
    update_data = shift_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(shift, field, value)
    
    shift.updated_at = datetime.now()
    
    return shift

@router.delete("/{shift_id}")
async def delete_shift(shift_id: int):
    global shifts_db
    
    shift = next((s for s in shifts_db if s.id == shift_id), None)
    if not shift:
        raise HTTPException(status_code=404, detail="Смена не найдена")
    
    shifts_db = [s for s in shifts_db if s.id != shift_id]
    
    return {"message": "Смена успешно удалена"}

@router.get("/crew/{crew_id}", response_model=List[Shift])
async def get_shifts_by_crew(crew_id: int):
    crew_shifts = [s for s in shifts_db if s.crew_id == crew_id]
    return crew_shifts
