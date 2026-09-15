from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.api.reportes import router as reportes_router
from app.database.connection import Base, engine, get_db
from app.models.mascota import Mascota
from app.models.reporte import Reporte


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Pet Rescue API",
    description="API para la gestión de mascotas extraviadas",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(reportes_router)


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
    result = db.execute(
        text("SELECT COUNT(*) FROM mascotas")
    ).scalar()

    motor = (
        "sqlite"
        if engine.url.drivername.startswith("sqlite")
        else "postgresql"
    )

    return {
        "status": "ok",
        "database": "conectada",
        "motor": motor,
        "mascotas_registradas": result,
    }