from typing import Literal

from pydantic import BaseModel, ConfigDict


EstadoReporte = Literal[
    "Activo",
    "Encontrado",
    "Cerrado",
]


class EstadoReporteUpdate(BaseModel):
    estado: EstadoReporte


class EstadoReporteOut(BaseModel):
    id: int
    codigo: str
    estado: EstadoReporte
    mensaje: str

    model_config = ConfigDict(
        from_attributes=True,
    )