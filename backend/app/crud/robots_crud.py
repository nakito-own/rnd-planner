from sqlalchemy.orm import Session
from app.models.database_models import Robots
from app.models.schemas import RobotsCreate, RobotsUpdate
from typing import List, Optional

def get_robot(db: Session, robot_id: int) -> Optional[Robots]:
    return db.query(Robots).filter(Robots.id == robot_id).first()

def get_robot_by_name(db: Session, name: int) -> Optional[Robots]:
    return db.query(Robots).filter(Robots.name == name).first()

def get_robots(db: Session, skip: int = 0, limit: int = 100) -> List[Robots]:
    return db.query(Robots).offset(skip).limit(limit).all()

def get_robots_by_series(db: Session, series: int) -> List[Robots]:
    return db.query(Robots).filter(Robots.series == series).all()

def get_robots_with_blockers(db: Session) -> List[Robots]:
    return db.query(Robots).filter(Robots.has_blockers == True).all()

def create_robot(db: Session, robot: RobotsCreate) -> Robots:
    db_robot = Robots(**robot.dict())
    db.add(db_robot)
    db.commit()
    db.refresh(db_robot)
    return db_robot

def update_robot(db: Session, robot_id: int, robot: RobotsUpdate) -> Optional[Robots]:
    db_robot = get_robot(db, robot_id)
    if db_robot:
        update_data = robot.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_robot, field, value)
        db.commit()
        db.refresh(db_robot)
    return db_robot

def delete_robot(db: Session, robot_id: int) -> bool:
    db_robot = get_robot(db, robot_id)
    if db_robot:
        db.delete(db_robot)
        db.commit()
        return True
    return False
