# ============================================================
# Pet Rescue - Schemas Pydantic: Avistamiento (HU10)
# ============================================================
from datetime import date, datetime, time

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
)


class AvistamientoCreate(BaseModel):
    descripcion: str = Field(
        min_length=10,
        max_length=500,
    )
    ubicacion_aproximada: str = Field(
        min_length=3,
        max_length=200,
    )
    fecha_avistamiento: date
    hora_avistamiento: time | None = None

    @field_validator("descripcion", "ubicacion_aproximada")
    @classmethod
    def limpiar_texto(cls, valor: str) -> str:
        valor_limpio = valor.strip()

        if not valor_limpio:
            raise ValueError(
                "El campo no puede estar vacío."
            )

        return valor_limpio

    @field_validator("fecha_avistamiento")
    @classmethod
    def validar_fecha(cls, valor: date) -> date:
        if valor > date.today():
            raise ValueError(
                "La fecha del avistamiento no puede ser futura."
            )

        return valor


class AvistamientoOut(BaseModel):
    id: int
    reporte_id: int
    descripcion: str
    ubicacion_aproximada: str
    fecha_avistamiento: date
    hora_avistamiento: time | None
    fecha_creacion: datetime

    model_config = ConfigDict(
        from_attributes=True,
    )