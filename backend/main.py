from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import dashboards, tables, shifts, crews, tg_scenarios, robots, transport, tasks

app = FastAPI(
    title="R&D Planner API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(dashboards.router, prefix="/api/v1/dashboards", tags=["dashboards"])
app.include_router(tables.router, prefix="/api/v1/tables", tags=["tables"])
app.include_router(shifts.router, prefix="/api/v1/shifts", tags=["shifts"])
app.include_router(crews.router, prefix="/api/v1/crews", tags=["crews"])
app.include_router(robots.router, prefix="/api/v1/robots", tags=["robots"])
app.include_router(transport.router, prefix="/api/v1/transport", tags=["transport"])
app.include_router(tasks.router, prefix="/api/v1/tasks", tags=["tasks"])
app.include_router(tg_scenarios.router, prefix="/api/v1/tg-scenarios", tags=["tg-scenarios"])

@app.get("/")
async def root():
    return {"message": "R&D Planner API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
