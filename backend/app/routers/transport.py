from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from app.models.schemas import Transport, TransportCreate, TransportUpdate
from app.crud import transport_crud
from app.database import get_db
from sqlalchemy.orm import Session

router = APIRouter()

@router.get("/", response_model=List[Transport])
async def get_transports(
    skip: int = 0,
    limit: int = 100,
    carsharing: Optional[bool] = None,
    corporate: Optional[bool] = None,
    auto_vc: Optional[bool] = None,
    db: Session = Depends(get_db)
):
    """Get all transports with optional filtering"""
    try:
        if carsharing is not None or corporate is not None or auto_vc is not None:
            transports = transport_crud.get_transports_by_type(
                db, carsharing=carsharing, corporate=corporate, auto_vc=auto_vc
            )
        else:
            transports = transport_crud.get_transports(db, skip=skip, limit=limit)
        return transports
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching transports: {str(e)}")

@router.get("/{transport_id}", response_model=Transport)
async def get_transport(
    transport_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific transport by ID"""
    transport = transport_crud.get_transport(db, transport_id)
    if not transport:
        raise HTTPException(status_code=404, detail="Transport not found")
    return transport

@router.post("/", response_model=Transport)
async def create_transport(
    transport: TransportCreate,
    db: Session = Depends(get_db)
):
    """Create a new transport"""
    try:
        return transport_crud.create_transport(db, transport)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error creating transport: {str(e)}")

@router.put("/{transport_id}", response_model=Transport)
async def update_transport(
    transport_id: int,
    transport: TransportUpdate,
    db: Session = Depends(get_db)
):
    """Update an existing transport"""
    try:
        updated_transport = transport_crud.update_transport(db, transport_id, transport)
        if not updated_transport:
            raise HTTPException(status_code=404, detail="Transport not found")
        return updated_transport
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error updating transport: {str(e)}")

@router.delete("/{transport_id}")
async def delete_transport(
    transport_id: int,
    db: Session = Depends(get_db)
):
    """Delete a transport"""
    try:
        success = transport_crud.delete_transport(db, transport_id)
        if not success:
            raise HTTPException(status_code=404, detail="Transport not found")
        return {"message": "Transport deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error deleting transport: {str(e)}")
