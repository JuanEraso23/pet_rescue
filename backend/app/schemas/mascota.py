# ============================================================
# Pet Rescue - Schema Pydantic: Mascota
# ============================================================
from pydantic import BaseModel
from typing import Optional


class MascotaBase(BaseModel):
    nombre: Optional[str] = None
    especie: str
    raza: Optional[str] = None
    color: str
    tamano: str
    edad_aproximada: Optional[int] = None
    senas_particulares: Optional[str] = None


class MascotaCreate(MascotaBase):
    pass


class MascotaOut(MascotaBase):
    id: int

    class Config:
        from_attributes = True
