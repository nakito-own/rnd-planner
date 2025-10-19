from sqlalchemy.orm import Session
from app.models.database_models import Transport
from app.models.schemas import TransportCreate, TransportUpdate
from typing import List, Optional

def get_transport(db: Session, transport_id: int) -> Optional[Transport]:
    return db.query(Transport).filter(Transport.id == transport_id).first()

def get_transports(db: Session, skip: int = 0, limit: int = 100) -> List[Transport]:
    return db.query(Transport).offset(skip).limit(limit).all()

def get_transports_by_type(db: Session, carsharing: bool = None, corporate: bool = None, auto_vc: bool = None) -> List[Transport]:
    query = db.query(Transport)
    if carsharing is not None:
        query = query.filter(Transport.carsharing == carsharing)
    if corporate is not None:
        query = query.filter(Transport.corporate == corporate)
    if auto_vc is not None:
        query = query.filter(Transport.auto_vc == auto_vc)
    return query.all()

def create_transport(db: Session, transport: TransportCreate) -> Transport:
    db_transport = Transport(**transport.dict())
    db.add(db_transport)
    db.commit()
    db.refresh(db_transport)
    return db_transport

def update_transport(db: Session, transport_id: int, transport: TransportUpdate) -> Optional[Transport]:
    db_transport = get_transport(db, transport_id)
    if db_transport:
        update_data = transport.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_transport, field, value)
        db.commit()
        db.refresh(db_transport)
    return db_transport

def delete_transport(db: Session, transport_id: int) -> bool:
    db_transport = get_transport(db, transport_id)
    if db_transport:
        db.delete(db_transport)
        db.commit()
        return True
    return False
