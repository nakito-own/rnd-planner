#!/bin/bash


echo "🚀 Starting R&D Planner with Docker..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker with Compose support."
    exit 1
fi

echo "🛑 Stopping existing containers..."
docker compose down

if [ "$1" = "--clean" ]; then
    echo "🧹 Cleaning up old images..."
    docker compose down --rmi all
fi

echo "🔨 Building and starting containers..."
docker compose up --build -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "📊 Container status:"
docker compose ps

echo "📋 Recent logs:"
docker compose logs --tail=20

echo ""
echo "✅ R&D Planner is running!"
echo "🌐 Web App: http://localhost:8080"
echo "🌐 Backend API: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo "🗄️ MySQL: localhost:3307"
echo ""
echo "📖 Useful commands:"
echo "  View logs: docker compose logs -f"
echo "  Stop: docker compose down"
echo "  Restart: docker compose restart"
echo "  Shell access: docker compose exec backend bash"
