#!/bin/bash


SERVICE=${1:-""}

echo "📋 R&D Planner Docker Logs"
echo "=========================="

if [ -z "$SERVICE" ]; then
    echo "📊 All services logs:"
    docker compose logs -f
else
    echo "📊 Logs for service: $SERVICE"
        case $SERVICE in
        "backend"|"mysql"|"frontend")
            docker compose logs -f $SERVICE
            ;;
        *)
            echo "❌ Unknown service: $SERVICE"
            echo "Available services: backend, mysql, frontend"
            exit 1
            ;;
    esac
fi
