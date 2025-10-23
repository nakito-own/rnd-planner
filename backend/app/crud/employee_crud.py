from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models.database_models import Employee, Crew
from app.models.schemas import EmployeeCreate, EmployeeUpdate
from typing import List, Optional

def get_employee(db: Session, employee_id: int) -> Optional[Employee]:
    return db.query(Employee).filter(Employee.id == employee_id).first()

def get_employees(db: Session, skip: int = 0, limit: int = 100) -> List[Employee]:
    return db.query(Employee).offset(skip).limit(limit).all()

def get_employees_with_filters(
    db: Session, 
    skip: int = 0, 
    limit: int = 100,
    body: str = None,
    crew_id: int = None,
    parking: bool = None,
    drive: bool = None,
    telemedicine: bool = None,
    access_to_auto_vc: bool = None
) -> List[Employee]:
    query = db.query(Employee)
    
    filters = []
    
    if body is not None:
        filters.append(Employee.body.ilike(f"%{body}%"))
    
    if crew_id is not None:
        filters.append(Employee.crew == crew_id)
    
    if parking is not None:
        filters.append(Employee.parking == parking)
    
    if drive is not None:
        filters.append(Employee.drive == drive)
    
    if telemedicine is not None:
        filters.append(Employee.telemedicine == telemedicine)
    
    if access_to_auto_vc is not None:
        filters.append(Employee.acces_to_auto_vc == access_to_auto_vc)
    
    if filters:
        query = query.filter(and_(*filters))
    
    return query.offset(skip).limit(limit).all()

def get_employees_by_crew(db: Session, crew_id: int) -> List[Employee]:
    return db.query(Employee).filter(Employee.crew == crew_id).all()

def crew_exists(db: Session, crew_id: int) -> bool:
    return db.query(Crew).filter(Crew.id == crew_id).first() is not None

def create_employee(db: Session, employee: EmployeeCreate) -> Employee:
    # Проверяем, что crew существует, если указан
    if employee.crew is not None and not crew_exists(db, employee.crew):
        raise ValueError(f"Crew with id {employee.crew} does not exist")
    
    db_employee = Employee(**employee.dict())
    db.add(db_employee)
    db.commit()
    db.refresh(db_employee)
    return db_employee

def update_employee(db: Session, employee_id: int, employee: EmployeeUpdate) -> Optional[Employee]:
    db_employee = get_employee(db, employee_id)
    if db_employee:
        update_data = employee.dict(exclude_unset=True)
        
        # Проверяем, что crew существует, если указан
        if 'crew' in update_data and update_data['crew'] is not None:
            if not crew_exists(db, update_data['crew']):
                raise ValueError(f"Crew with id {update_data['crew']} does not exist")
        
        for field, value in update_data.items():
            setattr(db_employee, field, value)
        db.commit()
        db.refresh(db_employee)
    return db_employee

def delete_employee(db: Session, employee_id: int) -> bool:
    db_employee = get_employee(db, employee_id)
    if db_employee:
        db.delete(db_employee)
        db.commit()
        return True
    return False
