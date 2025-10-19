from fastapi import APIRouter, HTTPException
from typing import List
from app.models.schemas import Table, TableCreate, TableUpdate
from datetime import datetime

router = APIRouter()

tables_db = []
table_id_counter = 1

@router.get("/", response_model=List[Table])
async def get_tables():
    return tables_db

@router.get("/{table_id}", response_model=Table)
async def get_table(table_id: int):
    table = next((t for t in tables_db if t.id == table_id), None)
    if not table:
        raise HTTPException(status_code=404, detail="Таблица не найдена")
    return table

@router.post("/", response_model=Table)
async def create_table(table: TableCreate):
    global table_id_counter
    
    new_table = Table(
        id=table_id_counter,
        name=table.name,
        description=table.description,
        table_type=table.table_type,
        columns=table.columns,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        owner_id=1
    )
    
    tables_db.append(new_table)
    table_id_counter += 1
    
    return new_table

@router.put("/{table_id}", response_model=Table)
async def update_table(table_id: int, table_update: TableUpdate):
    table = next((t for t in tables_db if t.id == table_id), None)
    if not table:
        raise HTTPException(status_code=404, detail="Таблица не найдена")
    
    update_data = table_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(table, field, value)
    
    table.updated_at = datetime.now()
    
    return table

@router.delete("/{table_id}")
async def delete_table(table_id: int):
    global tables_db
    
    table = next((t for t in tables_db if t.id == table_id), None)
    if not table:
        raise HTTPException(status_code=404, detail="Таблица не найдена")
    
    tables_db = [t for t in tables_db if t.id != table_id]
    
    return {"message": "Таблица успешно удалена"}
