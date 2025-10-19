from fastapi import APIRouter, HTTPException
from typing import List
from app.models.schemas import TgScenario, TgScenarioCreate, TgScenarioUpdate
from datetime import datetime

router = APIRouter()

tg_scenarios_db = []
scenario_id_counter = 1

@router.get("/", response_model=List[TgScenario])
async def get_tg_scenarios():
    return tg_scenarios_db

@router.get("/{scenario_id}", response_model=TgScenario)
async def get_tg_scenario(scenario_id: int):
    scenario = next((s for s in tg_scenarios_db if s.id == scenario_id), None)
    if not scenario:
        raise HTTPException(status_code=404, detail="TG сценарий не найден")
    return scenario

@router.post("/", response_model=TgScenario)
async def create_tg_scenario(scenario: TgScenarioCreate):
    global scenario_id_counter
    
    new_scenario = TgScenario(
        id=scenario_id_counter,
        name=scenario.name,
        description=scenario.description,
        trigger_keywords=scenario.trigger_keywords,
        message_template=scenario.message_template,
        status=scenario.status,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        owner_id=1
    )
    
    tg_scenarios_db.append(new_scenario)
    scenario_id_counter += 1
    
    return new_scenario

@router.put("/{scenario_id}", response_model=TgScenario)
async def update_tg_scenario(scenario_id: int, scenario_update: TgScenarioUpdate):
    scenario = next((s for s in tg_scenarios_db if s.id == scenario_id), None)
    if not scenario:
        raise HTTPException(status_code=404, detail="TG сценарий не найден")
    
    update_data = scenario_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(scenario, field, value)
    
    scenario.updated_at = datetime.now()
    
    return scenario

@router.delete("/{scenario_id}")
async def delete_tg_scenario(scenario_id: int):
    global tg_scenarios_db
    
    scenario = next((s for s in tg_scenarios_db if s.id == scenario_id), None)
    if not scenario:
        raise HTTPException(status_code=404, detail="TG сценарий не найден")
    
    tg_scenarios_db = [s for s in tg_scenarios_db if s.id != scenario_id]
    
    return {"message": "TG сценарий успешно удален"}

@router.get("/status/{status}", response_model=List[TgScenario])
async def get_tg_scenarios_by_status(status: str):
    scenarios = [s for s in tg_scenarios_db if s.status == status]
    return scenarios

@router.post("/{scenario_id}/activate")
async def activate_tg_scenario(scenario_id: int):
    scenario = next((s for s in tg_scenarios_db if s.id == scenario_id), None)
    if not scenario:
        raise HTTPException(status_code=404, detail="TG сценарий не найден")
    
    scenario.status = "active"
    scenario.updated_at = datetime.now()
    
    return {"message": "TG сценарий активирован"}

@router.post("/{scenario_id}/deactivate")
async def deactivate_tg_scenario(scenario_id: int):
    scenario = next((s for s in tg_scenarios_db if s.id == scenario_id), None)
    if not scenario:
        raise HTTPException(status_code=404, detail="TG сценарий не найден")
    
    scenario.status = "draft"
    scenario.updated_at = datetime.now()
    
    return {"message": "TG сценарий деактивирован"}
