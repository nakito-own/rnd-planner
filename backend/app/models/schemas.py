from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

class DashboardType(str, Enum):
    RESEARCH = "research"
    PROJECT = "project"
    ANALYTICS = "analytics"
    PERFORMANCE = "performance"

class TableType(str, Enum):
    RESEARCH_DATA = "research_data"
    PROJECT_DATA = "project_data"
    TEAM_DATA = "team_data"
    RESOURCE_DATA = "resource_data"

class ShiftStatus(str, Enum):
    PLANNED = "planned"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class CrewRole(str, Enum):
    LEAD = "lead"
    RESEARCHER = "researcher"
    ANALYST = "analyst"
    TECHNICIAN = "technician"
    MANAGER = "manager"

class ScenarioStatus(str, Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    COMPLETED = "completed"
    ARCHIVED = "archived"

class TaskType(str, Enum):
    ROUTE = "route"
    CARPET = "carpet"
    DEMO = "demo"
    CUSTOM = "custom"

class DashboardBase(BaseModel):
    name: str = Field(...)
    description: Optional[str] = Field(None)
    dashboard_type: DashboardType = Field(...)
    is_public: bool = Field(False)

class DashboardCreate(DashboardBase):
    pass

class DashboardUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    dashboard_type: Optional[DashboardType] = None
    is_public: Optional[bool] = None

class Dashboard(DashboardBase):
    id: int
    created_at: datetime
    updated_at: datetime
    owner_id: int

    class Config:
        from_attributes = True

class TableBase(BaseModel):
    name: str = Field(...)
    description: Optional[str] = Field(None)
    table_type: TableType = Field(...)
    columns: List[str] = Field(...)

class TableCreate(TableBase):
    pass

class TableUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    table_type: Optional[TableType] = None
    columns: Optional[List[str]] = None

class Table(TableBase):
    id: int
    created_at: datetime
    updated_at: datetime
    owner_id: int

    class Config:
        from_attributes = True

class LegacyShiftBase(BaseModel):
    name: str = Field(...)
    start_time: datetime = Field(...)
    end_time: datetime = Field(...)
    status: ShiftStatus = Field(ShiftStatus.PLANNED)
    description: Optional[str] = Field(None)

class LegacyShiftCreate(LegacyShiftBase):
    crew_id: int = Field(...)

class LegacyShiftUpdate(BaseModel):
    name: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    status: Optional[ShiftStatus] = None
    description: Optional[str] = None
    crew_id: Optional[int] = None

class LegacyShift(LegacyShiftBase):
    id: int
    crew_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class CrewBase(BaseModel):
    name: str = Field(...)
    description: Optional[str] = Field(None)
    max_members: int = Field(10)

class CrewCreate(CrewBase):
    pass

class CrewUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    max_members: Optional[int] = None

class CrewMemberBase(BaseModel):
    user_id: int = Field(...)
    role: CrewRole = Field(...)

class CrewMemberCreate(CrewMemberBase):
    crew_id: int = Field(...)

class CrewMember(CrewMemberBase):
    id: int
    crew_id: int
    joined_at: datetime

    class Config:
        from_attributes = True

class Crew(CrewBase):
    id: int
    created_at: datetime
    updated_at: datetime
    owner_id: int
    members: List[CrewMember] = []

    class Config:
        from_attributes = True

class TgScenarioBase(BaseModel):
    name: str = Field(...)
    description: Optional[str] = Field(None)
    trigger_keywords: List[str] = Field(...)
    message_template: str = Field(...)
    status: ScenarioStatus = Field(ScenarioStatus.DRAFT)

class TgScenarioCreate(TgScenarioBase):
    pass

class TgScenarioUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    trigger_keywords: Optional[List[str]] = None
    message_template: Optional[str] = None
    status: Optional[ScenarioStatus] = None

class TgScenario(TgScenarioBase):
    id: int
    created_at: datetime
    updated_at: datetime
    owner_id: int

    class Config:
        from_attributes = True

class EmployeeBase(BaseModel):
    firstname: str = Field(...)
    lastname: str = Field(...)
    patronymic: Optional[str] = Field(None)
    tg: Optional[str] = Field(None)
    staff: Optional[str] = Field(None)
    body: Optional[str] = Field(None)
    drive: bool = Field(False)
    parking: bool = Field(False)
    telemedicine: bool = Field(False)
    attorney: bool = Field(False)
    acces_to_auto_vc: bool = Field(False)
    crew: Optional[int] = Field(None)

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeUpdate(BaseModel):
    firstname: Optional[str] = None
    lastname: Optional[str] = None
    patronymic: Optional[str] = None
    tg: Optional[str] = None
    staff: Optional[str] = None
    body: Optional[str] = None
    drive: Optional[bool] = None
    parking: Optional[bool] = None
    telemedicine: Optional[bool] = None
    attorney: Optional[bool] = None
    acces_to_auto_vc: Optional[bool] = None
    crew: Optional[int] = None

class Employee(EmployeeBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class TransportBase(BaseModel):
    name: str = Field(...)
    model: Optional[str] = Field(None)
    gov_number: Optional[str] = Field(None)
    carsharing: bool = Field(False)
    corporate: bool = Field(False)
    auto_vc: bool = Field(False)
    has_blockers: bool = Field(False)

class TransportCreate(TransportBase):
    pass

class TransportUpdate(BaseModel):
    name: Optional[str] = None
    model: Optional[str] = None
    gov_number: Optional[str] = None
    carsharing: Optional[bool] = None
    corporate: Optional[bool] = None
    auto_vc: Optional[bool] = None
    has_blockers: Optional[bool] = None

class Transport(TransportBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class RobotsBase(BaseModel):
    name: int = Field(...)
    series: int = Field(...)
    has_blockers: bool = Field(False)

class RobotsCreate(RobotsBase):
    pass

class RobotsUpdate(BaseModel):
    name: Optional[int] = None
    series: Optional[int] = None
    has_blockers: Optional[bool] = None

class Robots(RobotsBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ShiftBase(BaseModel):
    date: datetime = Field(..., description="Дата смены")
    time_start: datetime = Field(..., description="Время начала смены")
    time_end: datetime = Field(..., description="Время окончания смены")

class ShiftCreate(ShiftBase):
    pass

class ShiftUpdate(BaseModel):
    date: Optional[datetime] = None
    time_start: Optional[datetime] = None
    time_end: Optional[datetime] = None

class Shift(ShiftBase):
    id: int
    edited_at: datetime
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class TaskForShift(BaseModel):
    id: int
    executor: int
    robot_name: Optional[int] = None
    transport_id: Optional[int] = None
    time_start: datetime
    time_end: datetime
    type: TaskType
    geojson: Optional[Dict[str, Any]] = None
    geojson_filename: Optional[str] = None
    tickets: List[str]
    created_at: datetime
    updated_at: datetime
    # Дополнительная информация
    executor_name: Optional[str] = None  # ФИО исполнителя
    transport_name: Optional[str] = None  # Название транспорта
    transport_gov_number: Optional[str] = None  # Гос номер транспорта

    class Config:
        from_attributes = True

class ShiftWithTasks(ShiftBase):
    id: int
    edited_at: datetime
    created_at: datetime
    updated_at: datetime
    tasks: List[TaskForShift] = []

    class Config:
        from_attributes = True

class EnrichedTaskForShift(BaseModel):
    id: int
    executor: int
    robot_name: Optional[int] = None
    transport_id: Optional[int] = None
    time_start: datetime
    time_end: datetime
    type: TaskType
    geojson: Optional[Dict[str, Any]] = None
    geojson_filename: Optional[str] = None
    tickets: List[str]
    created_at: datetime
    updated_at: datetime
    executor_name: Optional[str] = None
    transport_name: Optional[str] = None
    transport_gov_number: Optional[str] = None

    class Config:
        from_attributes = True

class ShiftWithEnrichedTasks(ShiftBase):
    id: int
    edited_at: datetime
    created_at: datetime
    updated_at: datetime
    tasks: List[EnrichedTaskForShift] = []

    class Config:
        from_attributes = True

class TaskBase(BaseModel):
    shift_id: int = Field(..., description="ID смены, к которой привязана задача")
    executor: int = Field(..., description="ID сотрудника исполнителя")
    robot_name: Optional[int] = Field(None, description="Номер робота")
    transport_id: Optional[int] = Field(None, description="ID выделенного для задачи транспорта")
    time_start: datetime = Field(..., description="Время начала задачи")
    time_end: datetime = Field(..., description="Время окончания задачи")
    type: TaskType = Field(..., description="Тип задачи")
    geojson: Optional[Dict[str, Any]] = Field(None, description="GeoJSON данные для маршрута")
    geojson_filename: Optional[str] = Field(None, description="Имя загруженного GeoJSON файла")
    tickets: List[str] = Field(..., description="Ссылки на сторонний ресурс")

    @validator('geojson')
    def validate_geojson(cls, v, values):
        task_type = values.get('type')
        if task_type == TaskType.ROUTE and v is None:
            raise ValueError('geojson обязателен для задач типа route')
        return v

    @validator('tickets')
    def validate_tickets(cls, v):
        if not v or len(v) == 0:
            raise ValueError('tickets не может быть пустым')
        return v

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    shift_id: Optional[int] = None
    executor: Optional[int] = None
    robot_name: Optional[int] = None
    transport_id: Optional[int] = None
    time_start: Optional[datetime] = None
    time_end: Optional[datetime] = None
    type: Optional[TaskType] = None
    geojson: Optional[Dict[str, Any]] = None
    geojson_filename: Optional[str] = None
    tickets: Optional[List[str]] = None

class Task(TaskBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
