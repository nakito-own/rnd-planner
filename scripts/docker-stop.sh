#!/bin/bash


echo "🛑 Stopping R&D Planner Docker containers..."

docker compose down

if [ "$1" = "--clean-data" ]; then
    echo "🧹 Removing database volumes..."
    docker compose down -v
    echo "⚠️  All data has been removed!"
fi

if [ "$1" = "--clean-images" ]; then
    echo "🧹 Removing Docker images..."
    docker compose down --rmi all
fi

echo "✅ R&D Planner stopped successfully!"
