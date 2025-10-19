#!/usr/bin/env python3

from sqlalchemy import create_engine
from app.database import Base, engine
from app.models.database_models import Employee, Transport, Robots, Shift, Crew
from app.config import settings

def init_database():
    print("Создание таблиц в базе данных...")
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Таблицы успешно созданы!")
    except Exception as e:
        print(f"❌ Ошибка при создании таблиц: {e}")
        raise

def create_sample_data():
    from sqlalchemy.orm import sessionmaker
    from datetime import datetime, timedelta
    
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        crew = Crew(
            name="Команда разработки",
            max_members=5,
            owner_id=1
        )
        db.add(crew)
        db.flush()
        
        employees = [
            Employee(
                firstname="Данил",
                lastname="Волков",
                patronymic="Сергеевич",
                tg="@steg1",
                staff="steg1",
                body="@nakito-own",
                drive=True,
                parking=True,
                telemedicine=True,
                attorney=False,
                acces_to_auto_vc=False,
                crew=crew.id
            ),
            Employee(
                firstname="Илья",
                lastname="Воронов",
                patronymic="Александрович",
                tg="@isvoronov",
                staff="isvoronov",
                body="@nakito-own",
                drive=False,
                parking=True,
                telemedicine=True,
                attorney=True,
                acces_to_auto_vc=True,
                crew=crew.id
            )
        ]
        
        for emp in employees:
            db.add(emp)
        
        transports = [
            Transport(
                name="Modris",
                model="Citroen Berlingo",
                gov_number="А123БВ77",
                carsharing=False,
                corporate=True,
                auto_vc=False
            ),
            Transport(
                name="Каршеринг",
                model="Sollers Atlant",
                gov_number="В456ГД77",
                carsharing=True,
                corporate=False,
                auto_vc=False
            )
        ]
        
        for transport in transports:
            db.add(transport)
        
        robots = [
            Robots(
                name=188,
                series=1,
                has_blockers=False
            ),
            Robots(
                name=295,
                series=2,
                has_blockers=False
            )
        ]
        
        for robot in robots:
            db.add(robot)
        
        db.flush()
        
        now = datetime.now()
        shifts = [
            Shift(
                executor="Данил Волков",
                robot=robots[0].id,
                transport_name="Modris",
                time_start=now,
                time_end=now + timedelta(hours=12),
                route=True,
                carpet=False,
                geojson={
                    "type": "FeatureCollection",
                    "features": [
                        {
                            "type": "Feature",
                            "geometry": {
                                "type": "Point",
                                "coordinates": [37.6173, 55.7558]
                            },
                            "properties": {
                                "name": "Москва"
                            }
                        }
                    ]
                }
            )
        ]
        
        for shift in shifts:
            db.add(shift)
        
        db.commit()
        print("✅ Примеры данных успешно созданы!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Ошибка при создании примеров данных: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("🚀 Инициализация базы данных...")
    print(f"🔗 Подключение к: {settings.DATABASE_URL}")
    
    try:
        init_database()
        create_sample_data()
        print("🎉 База данных успешно инициализирована!")
    except Exception as e:
        print(f"💥 Ошибка при инициализации базы данных: {e}")
        exit(1)
