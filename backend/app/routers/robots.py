from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.crud import robots_crud
from app.models.schemas import Robots, RobotsCreate, RobotsUpdate

router = APIRouter()

@router.get("/", response_model=List[Robots])
async def get_robots(
    skip: int = 0,
    limit: int = 100,
    series: int = None,
    has_blockers: bool = None,
    db: Session = Depends(get_db)
):
    """Get all robots with optional filtering"""
    if series is not None:
        return robots_crud.get_robots_by_series(db, series)
    elif has_blockers is not None and has_blockers:
        return robots_crud.get_robots_with_blockers(db)
    else:
        return robots_crud.get_robots(db, skip=skip, limit=limit)

@router.get("/{robot_id}", response_model=Robots)
async def get_robot(robot_id: int, db: Session = Depends(get_db)):
    """Get a specific robot by ID"""
    robot = robots_crud.get_robot(db, robot_id)
    if robot is None:
        raise HTTPException(status_code=404, detail="Robot not found")
    return robot

@router.post("/", response_model=Robots)
async def create_robot(robot: RobotsCreate, db: Session = Depends(get_db)):
    """Create a new robot"""
    # Check if robot with this name already exists
    existing_robot = robots_crud.get_robot_by_name(db, robot.name)
    if existing_robot:
        raise HTTPException(status_code=400, detail="Robot with this name already exists")
    
    return robots_crud.create_robot(db, robot)

@router.put("/{robot_id}", response_model=Robots)
async def update_robot(robot_id: int, robot: RobotsUpdate, db: Session = Depends(get_db)):
    """Update an existing robot"""
    # Check if robot with this name already exists (if name is being updated)
    if robot.name is not None:
        existing_robot = robots_crud.get_robot_by_name(db, robot.name)
        if existing_robot and existing_robot.id != robot_id:
            raise HTTPException(status_code=400, detail="Robot with this name already exists")
    
    updated_robot = robots_crud.update_robot(db, robot_id, robot)
    if updated_robot is None:
        raise HTTPException(status_code=404, detail="Robot not found")
    return updated_robot

@router.delete("/{robot_id}")
async def delete_robot(robot_id: int, db: Session = Depends(get_db)):
    """Delete a robot"""
    success = robots_crud.delete_robot(db, robot_id)
    if not success:
        raise HTTPException(status_code=404, detail="Robot not found")
    return {"message": "Robot deleted successfully"}
