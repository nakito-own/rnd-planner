from fastapi import APIRouter, HTTPException, Depends
from typing import List
from app.models.schemas import Dashboard, DashboardCreate, DashboardUpdate
from datetime import datetime

router = APIRouter()

dashboards_db = []
dashboard_id_counter = 1

@router.get("/", response_model=List[Dashboard])
async def get_dashboards():
    return dashboards_db

@router.get("/{dashboard_id}", response_model=Dashboard)
async def get_dashboard(dashboard_id: int):
    dashboard = next((d for d in dashboards_db if d.id == dashboard_id), None)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Дашборд не найден")
    return dashboard

@router.post("/", response_model=Dashboard)
async def create_dashboard(dashboard: DashboardCreate):
    global dashboard_id_counter
    
    new_dashboard = Dashboard(
        id=dashboard_id_counter,
        name=dashboard.name,
        description=dashboard.description,
        dashboard_type=dashboard.dashboard_type,
        is_public=dashboard.is_public,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        owner_id=1
    )
    
    dashboards_db.append(new_dashboard)
    dashboard_id_counter += 1
    
    return new_dashboard

@router.put("/{dashboard_id}", response_model=Dashboard)
async def update_dashboard(dashboard_id: int, dashboard_update: DashboardUpdate):
    dashboard = next((d for d in dashboards_db if d.id == dashboard_id), None)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Дашборд не найден")
    
    update_data = dashboard_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(dashboard, field, value)
    
    dashboard.updated_at = datetime.now()
    
    return dashboard

@router.delete("/{dashboard_id}")
async def delete_dashboard(dashboard_id: int):
    global dashboards_db
    
    dashboard = next((d for d in dashboards_db if d.id == dashboard_id), None)
    if not dashboard:
        raise HTTPException(status_code=404, detail="Дашборд не найден")
    
    dashboards_db = [d for d in dashboards_db if d.id != dashboard_id]
    
    return {"message": "Дашборд успешно удален"}
