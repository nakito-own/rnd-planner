from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, JSON, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

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
