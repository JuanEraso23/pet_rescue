from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.api.reportes import router as reportes_router
from app.database.connection import get_db

app = FastAPI(
    title="Pet Rescue API",
    description="API para la gestion de mascotas extraviadas",
    version="0.1.0",
)

app.include_router(reportes_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:8080",
        "http://localhost:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {
        "project": "Pet Rescue",
        "status": "running",
        "version": "0.1.0",
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok"
    }


@app.get("/health-db")
def health_db(db: Session = Depends(get_db)):
    """Verifica la conexion con PostgreSQL."""
    result = db.execute(text("SELECT COUNT(*) FROM mascotas")).scalar()
    return {
        "status": "ok",
        "database": "conectada",
        "mascotas_registradas": result,
    }
