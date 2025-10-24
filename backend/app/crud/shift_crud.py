from sqlalchemy.orm import Session, joinedload
from app.models.database_models import Shift, Task, Employee, Transport, Robots
from app.models.schemas import ShiftCreate, ShiftUpdate
from typing import List, Optional
from datetime import datetime

def get_shift(db: Session, shift_id: int) -> Optional[Shift]:
    return db.query(Shift).filter(Shift.id == shift_id).first()

def get_shift_with_tasks(db: Session, shift_id: int) -> Optional[Shift]:
    """Получить смену с задачами и связанными данными"""
    return db.query(Shift).options(
        joinedload(Shift.tasks).joinedload(Task.executor_rel),
        joinedload(Shift.tasks).joinedload(Task.transport_rel)
    ).filter(Shift.id == shift_id).first()

def enrich_task_data(task: Task, db: Session) -> dict:
    """Обогатить данные задачи дополнительной информацией"""
    task_data = {
        'id': task.id,
        'executor': task.executor,
        'robot_name': task.robot_name,
        'transport_id': task.transport_id,
        'time_start': task.time_start,
        'time_end': task.time_end,
        'type': task.type,
        'geojson': task.geojson,
        'tickets': task.tickets,
        'created_at': task.created_at,
        'updated_at': task.updated_at,
        'executor_name': None,
        'transport_name': None,
        'transport_gov_number': None
    }
    
    # Добавляем ФИО исполнителя
    if task.executor_rel:
        executor = task.executor_rel
        executor_name_parts = [executor.firstname, executor.lastname]
        if executor.patronymic:
            executor_name_parts.append(executor.patronymic)
        task_data['executor_name'] = ' '.join(executor_name_parts)
    
    # Добавляем информацию о транспорте
    if task.transport_rel:
        transport = task.transport_rel
        task_data['transport_name'] = transport.name
        task_data['transport_gov_number'] = transport.gov_number
    
    # Получаем имя робота по его ID
    robot = db.query(Robots).filter(Robots.id == task.robot_name).first()
    if robot:
        task_data['robot_name'] = robot.name
    
    return task_data

def get_shifts(db: Session, skip: int = 0, limit: int = 100) -> List[Shift]:
    return db.query(Shift).offset(skip).limit(limit).all()

def get_shifts_by_date(db: Session, date: datetime) -> List[Shift]:
    """Получить смены по конкретной дате"""
    try:
        # Создаем начало и конец дня для поиска
        start_of_day = date.replace(hour=0, minute=0, second=0, microsecond=0)
        end_of_day = date.replace(hour=23, minute=59, second=59, microsecond=999999)
        
        print(f"Searching shifts between {start_of_day} and {end_of_day}")
        
        shifts = db.query(Shift).filter(
            Shift.date >= start_of_day,
            Shift.date <= end_of_day
        ).all()
        
        print(f"Found {len(shifts)} shifts")
        return shifts
    except Exception as e:
        print(f"Error in get_shifts_by_date CRUD: {e}")
        raise

def get_shifts_by_date_range(db: Session, start_date: datetime, end_date: datetime) -> List[Shift]:
    """Получить смены в диапазоне дат"""
    return db.query(Shift).filter(
        Shift.date >= start_date,
        Shift.date <= end_date
    ).all()

def get_active_shifts(db: Session, current_time: datetime = None) -> List[Shift]:
    """Получить активные смены (текущее время между time_start и time_end)"""
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
