from pathlib import Path

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.fotografias import router as fotografias_router
from app.api.reportes import router as reportes_router
from app.database.connection import get_db


app = FastAPI(
    title="Pet Rescue API",
    description="API para la gestion de mascotas extraviadas",
    version="0.1.0",
)


CARPETA_UPLOADS = (
    Path(__file__).resolve().parent.parent
    / "uploads"
)

CARPETA_UPLOADS.mkdir(
    parents=True,
    exist_ok=True,
)


app.include_router(reportes_router)
app.include_router(fotografias_router)


app.mount(
    "/uploads",
    StaticFiles(directory=str(CARPETA_UPLOADS)),
    name="uploads",
)


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
        "status": "ok",
    }


@app.get("/health-db")
def health_db(db: Session = Depends(get_db)):
    """Verifica la conexion con PostgreSQL."""

    result = db.execute(
        text("SELECT COUNT(*) FROM mascotas")
    ).scalar()

    return {
        "status": "ok",
        "database": "conectada",
        "mascotas_registradas": result,
    }