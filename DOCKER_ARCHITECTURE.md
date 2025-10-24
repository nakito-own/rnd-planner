# Docker Architecture

## Новая архитектура с разделенными контейнерами

### Сервисы:

1. **mysql** - База данных MySQL
   - Порт: 3307
   - Контейнер: `rnd-planner-mysql`

2. **backend** - FastAPI сервер
   - Порт: 8000
   - Контейнер: `rnd-planner-backend`
   - Только API, без nginx

3. **frontend** - Flutter веб-приложение с nginx
   - Порт: 8080
   - Контейнер: `rnd-planner-frontend`
   - Статические файлы + nginx

### Преимущества новой архитектуры:

- ✅ **Разделение ответственности** - каждый контейнер решает свою задачу
- ✅ **Независимое масштабирование** - можно масштабировать frontend и backend отдельно
- ✅ **Упрощение backend** - убран nginx и supervisor
- ✅ **Лучшая производительность** - специализированный nginx для статики
- ✅ **Простота отладки** - логи nginx отдельно от FastAPI

### Команды для работы:

```bash
# Пересборка и запуск с новой архитектурой
./scripts/docker-rebuild.sh

# Обычный запуск
./scripts/docker-start.sh

# Остановка
./scripts/docker-stop.sh

# Просмотр логов
./scripts/docker-logs.sh [service_name]
```

### Доступ к сервисам:

- **Frontend (Flutter)**: http://localhost:8080
- **Backend API**: http://localhost:8000
- **MySQL**: localhost:3307

### Структура файлов:

```
frontend/
├── Dockerfile          # nginx для Flutter
├── nginx.conf         # конфигурация nginx
└── build/web/         # собранные файлы Flutter

backend/
├── Dockerfile          # только FastAPI
└── nginx.conf         # больше не используется
```

### Для разработки:

1. Соберите Flutter приложение: `cd frontend && flutter build web`
2. Запустите Docker: `./scripts/docker-rebuild.sh`
3. Откройте http://localhost:8080

### Обновление frontend без пересборки:

После изменения кода Flutter:
1. Пересоберите Flutter: `cd frontend && flutter build web`
2. Перезапустите frontend контейнер: `docker compose restart frontend`
3. Изменения применятся автоматически через volume

**Примечание**: Volume `./frontend/build/web:/usr/share/nginx/html:ro` монтирует собранные файлы, поэтому изменения видны без пересборки Docker образа.
