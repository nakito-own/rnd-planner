from sqlalchemy.orm import Session
from app.models.database_models import Task
from app.models.schemas import TaskCreate, TaskUpdate
from typing import List, Optional
from datetime import datetime

def get_task(db: Session, task_id: int) -> Optional[Task]:
    return db.query(Task).filter(Task.id == task_id).first()

def get_tasks(db: Session, skip: int = 0, limit: int = 100) -> List[Task]:
    return db.query(Task).offset(skip).limit(limit).all()

def get_tasks_by_shift(db: Session, shift_id: int) -> List[Task]:
    return db.query(Task).filter(Task.shift_id == shift_id).all()

def get_tasks_by_executor(db: Session, executor_id: int) -> List[Task]:
    return db.query(Task).filter(Task.executor == executor_id).all()

def get_tasks_by_robot(db: Session, robot_name: int) -> List[Task]:
    return db.query(Task).filter(Task.robot_name == robot_name).all()

def get_tasks_by_transport(db: Session, transport_id: int) -> List[Task]:
    return db.query(Task).filter(Task.transport_id == transport_id).all()

def get_tasks_by_date_range(db: Session, start_date: datetime, end_date: datetime) -> List[Task]:
    return db.query(Task).filter(
        Task.time_start >= start_date,
        Task.time_end <= end_date
    ).all()

def get_active_tasks(db: Session, current_time: datetime = None) -> List[Task]:
    if current_time is None:
        current_time = datetime.now()
    return db.query(Task).filter(
        Task.time_start <= current_time,
        Task.time_end >= current_time
    ).all()

def get_tasks_by_type(db: Session, task_type: str) -> List[Task]:
    return db.query(Task).filter(Task.type == task_type).all()

def create_task(db: Session, task: TaskCreate) -> Task:
    db_task = Task(**task.dict())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

def update_task(db: Session, task_id: int, task: TaskUpdate) -> Optional[Task]:
    db_task = get_task(db, task_id)
    if db_task:
        update_data = task.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_task, field, value)
        db.commit()
        db.refresh(db_task)
    return db_task

def delete_task(db: Session, task_id: int) -> bool:
    db_task = get_task(db, task_id)
    if db_task:
        db.delete(db_task)
        db.commit()
        return True
    return False
