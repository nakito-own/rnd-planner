#!/bin/bash

echo "🔄 Rebuilding Flutter web app"
echo "=============================="

# Пересобираем Flutter приложение
echo "📱 Building Flutter web app..."
cd frontend
flutter build web
cd ..

# Перезапускаем frontend контейнер
echo "🔄 Restarting frontend container..."
docker compose restart frontend

echo "✅ Done! Frontend updated at http://localhost:8080"
echo ""
echo "📋 To view logs: ./scripts/docker-logs.sh frontend"
