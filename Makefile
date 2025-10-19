.PHONY: help start stop restart logs clean build shell test

help:
	@echo "🚀 R&D Planner Docker Commands"
	@echo "=============================="
	@echo "start     - Запустить все сервисы"
	@echo "stop      - Остановить все сервисы"
	@echo "restart   - Перезапустить все сервисы"
	@echo "logs      - Показать логи всех сервисов"
	@echo "logs-backend - Показать логи бекенда"
	@echo "logs-mysql   - Показать логи MySQL"
	@echo "build     - Пересобрать образы"
	@echo "build-flutter - Собрать Flutter веб-приложение"
	@echo "clean     - Очистить контейнеры и образы"
	@echo "clean-data - Очистить данные базы данных"
	@echo "shell     - Подключиться к контейнеру бекенда"
	@echo "test      - Запустить тесты"
	@echo "status    - Показать статус контейнеров"

start:
	@echo "🚀 Starting R&D Planner..."
	@./scripts/docker-start.sh

stop:
	@echo "🛑 Stopping R&D Planner..."
	@./scripts/docker-stop.sh

restart:
	@echo "🔄 Restarting R&D Planner..."
	@docker compose restart

logs:
	@./scripts/docker-logs.sh

logs-backend:
	@./scripts/docker-logs.sh backend

logs-mysql:
	@./scripts/docker-logs.sh mysql

build:
	@echo "🔨 Building Docker images..."
	@docker compose build --no-cache

build-flutter:
	@echo "🌐 Building Flutter web application..."
	@./scripts/build-flutter.sh

clean:
	@echo "🧹 Cleaning up..."
	@./scripts/docker-stop.sh --clean-images

clean-data:
	@echo "🧹 Cleaning data..."
	@./scripts/docker-stop.sh --clean-data

shell:
	@echo "🐚 Connecting to backend container..."
	@docker compose exec backend bash

test:
	@echo "🧪 Running tests..."
	@docker compose exec backend python -m pytest

status:
	@echo "📊 Container Status:"
	@docker compose ps

dev:
	@echo "🚀 Starting development environment..."
	@docker compose up --build -d
	@echo "⏳ Waiting for services..."
	@sleep 15
	@echo "✅ Ready! Web app available at http://localhost:8080"
	@echo "🌐 Backend API: http://localhost:8000"
	@echo "📚 API Documentation: http://localhost:8000/docs"
