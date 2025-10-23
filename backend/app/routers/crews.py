from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.schemas import Crew, CrewCreate, CrewUpdate, CrewMember, CrewMemberCreate, Employee, EmployeeCreate, EmployeeUpdate
from app.crud import employee_crud
from app.database import get_db
from sqlalchemy.orm import Session
from datetime import datetime

router = APIRouter()

@router.get("/employees", response_model=List[Employee])
async def get_employees(
    skip: int = 0,
    limit: int = 100,
    body: str = None,
    crew_id: int = None,
    parking: bool = None,
    drive: bool = None,
    telemedicine: bool = None,
    access_to_auto_vc: bool = None,
    db: Session = Depends(get_db)
):
    return employee_crud.get_employees_with_filters(
        db, 
        skip=skip, 
        limit=limit,
        body=body,
        crew_id=crew_id,
        parking=parking,
        drive=drive,
        telemedicine=telemedicine,
        access_to_auto_vc=access_to_auto_vc
    )

@router.get("/employees/bodies", response_model=List[str])
async def get_employee_bodies(db: Session = Depends(get_db)):
    employees = employee_crud.get_employees(db)
    bodies = set()
    for employee in employees:
        if employee.body and employee.body.strip():
            bodies.add(employee.body.strip())
    return sorted(list(bodies))

@router.get("/employees/crews", response_model=List[int])
async def get_employee_crews(db: Session = Depends(get_db)):
    employees = employee_crud.get_employees(db)
    crews = set()
    for employee in employees:
        if employee.crew is not None:
            crews.add(employee.crew)
    return sorted(list(crews))

@router.get("/employees/{employee_id}", response_model=Employee)
async def get_employee(employee_id: int, db: Session = Depends(get_db)):
    employee = employee_crud.get_employee(db, employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="Сотрудник не найден")
    return employee

@router.post("/employees", response_model=Employee)
async def create_employee(employee: EmployeeCreate, db: Session = Depends(get_db)):
    try:
        return employee_crud.create_employee(db, employee)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.put("/employees/{employee_id}", response_model=Employee)
async def update_employee(employee_id: int, employee: EmployeeUpdate, db: Session = Depends(get_db)):
    try:
        updated_employee = employee_crud.update_employee(db, employee_id, employee)
        if not updated_employee:
            raise HTTPException(status_code=404, detail="Сотрудник не найден")
        return updated_employee
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/employees/{employee_id}")
async def delete_employee(employee_id: int, db: Session = Depends(get_db)):
    success = employee_crud.delete_employee(db, employee_id)
    if not success:
        raise HTTPException(status_code=404, detail="Сотрудник не найден")
    return {"message": "Сотрудник успешно удален"}

@router.get("/crews", response_model=List[dict])
async def get_crews_simple(db: Session = Depends(get_db)):
    from app.models.database_models import Crew
    crews = db.query(Crew).all()
    return [
        {
            "id": crew.id,
            "name": crew.name,
            "description": crew.description,
            "max_members": crew.max_members,
            "owner_id": crew.owner_id,
            "created_at": crew.created_at.isoformat() if crew.created_at else None,
            "updated_at": crew.updated_at.isoformat() if crew.updated_at else None,
        }
        for crew in crews
    ]

@router.post("/crews", response_model=dict)
async def create_crew_simple(
    crew_data: dict,
    db: Session = Depends(get_db)
):
    from app.models.database_models import Crew
    crew = Crew(
        name=crew_data.get("name", "Новая команда"),
        description=crew_data.get("description"),
        max_members=crew_data.get("max_members", 10),
        owner_id=crew_data.get("owner_id", 1)
    )
    db.add(crew)
    db.commit()
    db.refresh(crew)
    
    return {
        "id": crew.id,
        "name": crew.name,
        "description": crew.description,
        "max_members": crew.max_members,
        "owner_id": crew.owner_id,
        "created_at": crew.created_at.isoformat() if crew.created_at else None,
        "updated_at": crew.updated_at.isoformat() if crew.updated_at else None,
    }
