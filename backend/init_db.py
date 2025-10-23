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
        # Создаем первую команду
        crew1 = Crew(
            name="Команда разработки",
            max_members=5,
            owner_id=1
        )
        db.add(crew1)
        db.flush()
        
        # Создаем вторую команду
        crew2 = Crew(
            name="Команда тестирования",
            max_members=3,
            owner_id=1
        )
        db.add(crew2)
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
                crew=crew1.id
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
                crew=crew1.id
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
                date=now,
                time_start=now,
                time_end=now + timedelta(hours=12)
            )
        ]
        
        for shift in shifts:
            db.add(shift)
        
        db.flush()
        
        # Создаем задачи для смен
        from app.models.database_models import Task, TaskType
        
        tasks = [
            Task(
                shift_id=shifts[0].id,
                executor=employees[0].id,  # Данил Волков
                robot_name=robots[0].name,  # 188
                transport_id=transports[0].id,  # Modris
                time_start=now,
                time_end=now + timedelta(hours=8),
                type=TaskType.ROUTE,
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
                },
                tickets=["https://example.com/ticket1", "https://example.com/ticket2"]
            ),
            Task(
                shift_id=shifts[0].id,
                executor=employees[1].id,  # Илья Воронов
                robot_name=robots[1].name,  # 295
                transport_id=transports[1].id,  # Каршеринг
                time_start=now + timedelta(hours=4),
                time_end=now + timedelta(hours=12),
                type=TaskType.CARPET,
                geojson=None,
                tickets=["https://example.com/ticket3"]
            )
        ]
        
        for task in tasks:
            db.add(task)
        
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
