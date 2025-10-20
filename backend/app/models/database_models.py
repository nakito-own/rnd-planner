from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, JSON, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum

class TaskType(str, enum.Enum):
    ROUTE = "route"
    CARPET = "carpet"
    DEMO = "demo"
    CUSTOM = "custom"

class Employee(Base):
    __tablename__ = "employees"
    
    id = Column(Integer, primary_key=True, index=True)
    firstname = Column(String(100), nullable=False)
    lastname = Column(String(100), nullable=False)
    patronymic = Column(String(100), nullable=True)
    tg = Column(String(50), nullable=True)
    staff = Column(String(200), nullable=True)
    body = Column(String(200), nullable=True)
    drive = Column(Boolean, default=False)
    parking = Column(Boolean, default=False)
    telemedicine = Column(Boolean, default=False)
    attorney = Column(Boolean, default=False)
    acces_to_auto_vc = Column(Boolean, default=False)
    crew = Column(Integer, ForeignKey("crews.id"), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    crew_rel = relationship("Crew", back_populates="members")

class Transport(Base):
    __tablename__ = "transports"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    model = Column(String(200), nullable=True)
    gov_number = Column(String(20), nullable=True)
    carsharing = Column(Boolean, default=False)
    corporate = Column(Boolean, default=False)
    auto_vc = Column(Boolean, default=False)
    has_blockers = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class Robots(Base):
    __tablename__ = "robots"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(Integer, nullable=False, unique=True)
    series = Column(Integer, nullable=False)
    has_blockers = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class Shift(Base):
    __tablename__ = "shifts"
    
    id = Column(Integer, primary_key=True, index=True)
    executor = Column(String(200), nullable=False)
    robot = Column(Integer, ForeignKey("robots.id"), nullable=False)
    transport_name = Column(String(200), nullable=True)
    time_start = Column(DateTime(timezone=True), nullable=False)
    time_end = Column(DateTime(timezone=True), nullable=False)
    route = Column(Boolean, default=False)
    carpet = Column(Boolean, default=False)
    geojson = Column(JSON, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    robot_rel = relationship("Robots", back_populates="shifts")

Robots.shifts = relationship("Shift", back_populates="robot_rel")

class Crew(Base):
    __tablename__ = "crews"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    max_members = Column(Integer, default=10)
    owner_id = Column(Integer, nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    members = relationship("Employee", back_populates="crew_rel")

class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    shift_id = Column(Integer, ForeignKey("shifts.id"), nullable=False)
    executor = Column(Integer, ForeignKey("employees.id"), nullable=False)
    robot_name = Column(Integer, nullable=False)
    transport_id = Column(Integer, ForeignKey("transports.id"), nullable=True)
    time_start = Column(DateTime(timezone=True), nullable=False)
    time_end = Column(DateTime(timezone=True), nullable=False)
    type = Column(SQLEnum(TaskType), nullable=False)
    geojson = Column(JSON, nullable=True)
    tickets = Column(JSON, nullable=False)  # Список ссылок на сторонние ресурсы
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # Relationships
    shift_rel = relationship("Shift", back_populates="tasks")
    executor_rel = relationship("Employee", back_populates="tasks")
    transport_rel = relationship("Transport", back_populates="tasks")

# Add back_populates to existing models
Shift.tasks = relationship("Task", back_populates="shift_rel")
Employee.tasks = relationship("Task", back_populates="executor_rel")
Transport.tasks = relationship("Task", back_populates="transport_rel")
