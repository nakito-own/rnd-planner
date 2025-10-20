from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models.schemas import Task, TaskCreate, TaskUpdate, TaskType
from app.crud import task_crud

router = APIRouter()

@router.get("/", response_model=List[Task])
async def get_tasks(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """Получить список всех задач"""
    return task_crud.get_tasks(db, skip=skip, limit=limit)

@router.get("/{task_id}", response_model=Task)
async def get_task(task_id: int, db: Session = Depends(get_db)):
    """Получить задачу по ID"""
    task = task_crud.get_task(db, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    return task

@router.post("/", response_model=Task)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """Создать новую задачу"""
    return task_crud.create_task(db, task)

@router.put("/{task_id}", response_model=Task)
async def update_task(
    task_id: int, 
    task_update: TaskUpdate, 
    db: Session = Depends(get_db)
):
    """Обновить задачу"""
    task = task_crud.update_task(db, task_id, task_update)
    if not task:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    return task

@router.delete("/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    """Удалить задачу"""
    success = task_crud.delete_task(db, task_id)
    if not success:
        raise HTTPException(status_code=404, detail="Задача не найдена")
    return {"message": "Задача успешно удалена"}

@router.get("/shift/{shift_id}", response_model=List[Task])
async def get_tasks_by_shift(shift_id: int, db: Session = Depends(get_db)):
    """Получить задачи по ID смены"""
    return task_crud.get_tasks_by_shift(db, shift_id)

@router.get("/executor/{executor_id}", response_model=List[Task])
async def get_tasks_by_executor(executor_id: int, db: Session = Depends(get_db)):
    """Получить задачи по ID исполнителя"""
    return task_crud.get_tasks_by_executor(db, executor_id)

@router.get("/robot/{robot_name}", response_model=List[Task])
async def get_tasks_by_robot(robot_name: int, db: Session = Depends(get_db)):
    """Получить задачи по номеру робота"""
    return task_crud.get_tasks_by_robot(db, robot_name)

@router.get("/transport/{transport_id}", response_model=List[Task])
async def get_tasks_by_transport(transport_id: int, db: Session = Depends(get_db)):
    """Получить задачи по ID транспорта"""
    return task_crud.get_tasks_by_transport(db, transport_id)

@router.get("/type/{task_type}", response_model=List[Task])
async def get_tasks_by_type(task_type: TaskType, db: Session = Depends(get_db)):
    """Получить задачи по типу"""
    return task_crud.get_tasks_by_type(db, task_type)

@router.get("/active/", response_model=List[Task])
async def get_active_tasks(db: Session = Depends(get_db)):
    """Получить активные задачи (текущее время между time_start и time_end)"""
    return task_crud.get_active_tasks(db)

@router.get("/date-range/", response_model=List[Task])
async def get_tasks_by_date_range(
    start_date: datetime,
    end_date: datetime,
    db: Session = Depends(get_db)
):
    """Получить задачи в заданном диапазоне дат"""
    return task_crud.get_tasks_by_date_range(db, start_date, end_date)
