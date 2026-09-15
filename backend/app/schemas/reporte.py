# ============================================================
# Pet Rescue - Schema Pydantic: Reporte
# ============================================================
from pydantic import BaseModel
from datetime import date, time, datetime
from typing import Optional


class ReporteCreate(BaseModel):
    titulo: str
    descripcion: str
    especie: str
    nombre: Optional[str] = None
    raza: Optional[str] = None
    color: str
    tamano: str
    edad_aproximada: Optional[int] = None
    senas_particulares: Optional[str] = None
    ubicacion_extravio: str
    fecha_extravio: date
    hora_extravio: Optional[time] = None


class ReporteOut(BaseModel):
    id: int
    codigo: str
    estado: str
    fecha_creacion: datetime
    mensaje: str

    class Config:
        from_attributes = True
