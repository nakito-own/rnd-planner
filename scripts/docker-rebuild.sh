#!/bin/bash

echo "🔄 Rebuilding R&D Planner with new architecture"
echo "=============================================="

# Останавливаем контейнеры
echo "🛑 Stopping containers..."
docker compose down

# Пересобираем Flutter приложение
echo "📱 Building Flutter web app..."
cd frontend
flutter build web
cd ..

# Пересобираем Docker образы
echo "🐳 Rebuilding Docker images..."
docker compose build --no-cache

# Запускаем контейнеры
echo "🚀 Starting containers..."
docker compose up -d

echo "✅ Done! Services are running:"
echo "   - Frontend (Flutter): http://localhost:8080"
echo "   - Backend (FastAPI): http://localhost:8000"
echo "   - MySQL: localhost:3307"
echo ""
echo "📋 To view logs: ./scripts/docker-logs.sh [service_name]"
