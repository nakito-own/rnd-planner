from sqlalchemy.orm import Session
from app.models.database_models import Shift
from app.models.schemas import ShiftCreate, ShiftUpdate
from typing import List, Optional
from datetime import datetime

def get_shift(db: Session, shift_id: int) -> Optional[Shift]:
    return db.query(Shift).filter(Shift.id == shift_id).first()

def get_shifts(db: Session, skip: int = 0, limit: int = 100) -> List[Shift]:
    return db.query(Shift).offset(skip).limit(limit).all()

def get_shifts_by_robot(db: Session, robot_id: int) -> List[Shift]:
    return db.query(Shift).filter(Shift.robot == robot_id).all()

def get_shifts_by_executor(db: Session, executor: str) -> List[Shift]:
    return db.query(Shift).filter(Shift.executor == executor).all()

def get_shifts_by_date_range(db: Session, start_date: datetime, end_date: datetime) -> List[Shift]:
    return db.query(Shift).filter(
        Shift.time_start >= start_date,
        Shift.time_end <= end_date
    ).all()

def get_active_shifts(db: Session, current_time: datetime = None) -> List[Shift]:
    if current_time is None:
        current_time = datetime.now()
    return db.query(Shift).filter(
        Shift.time_start <= current_time,
        Shift.time_end >= current_time
    ).all()

def create_shift(db: Session, shift: ShiftCreate) -> Shift:
    db_shift = Shift(**shift.dict())
    db.add(db_shift)
    db.commit()
    db.refresh(db_shift)
    return db_shift

def update_shift(db: Session, shift_id: int, shift: ShiftUpdate) -> Optional[Shift]:
    db_shift = get_shift(db, shift_id)
    if db_shift:
        update_data = shift.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_shift, field, value)
        db.commit()
        db.refresh(db_shift)
    return db_shift

def delete_shift(db: Session, shift_id: int) -> bool:
    db_shift = get_shift(db, shift_id)
    if db_shift:
        db.delete(db_shift)
        db.commit()
        return True
    return False
