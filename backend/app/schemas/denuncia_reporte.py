# ============================================================
# Pet Rescue - Schemas Pydantic: DenunciaReporte (HU20)
# ============================================================
from datetime import datetime
from typing import Literal, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator


class DenunciaCreate(BaseModel):
    motivo: Literal["Falsa", "Duplicada", "Inadecuada", "Desactualizada", "Otro"]
    descripcion: Optional[str] = Field(default=None, max_length=500)

    @field_validator("descripcion")
    @classmethod
    def limpiar_descripcion(cls, valor: Optional[str]) -> Optional[str]:
        if valor is not None:
            return valor.strip()
        return valor


class DenunciaOut(BaseModel):
    id: int
    reporte_id: int
    motivo: str
    descripcion: Optional[str]
    estado: str
    fecha_creacion: datetime

    model_config = ConfigDict(from_attributes=True)


class DenunciaResumen(BaseModel):
    total: int
    pendientes: int