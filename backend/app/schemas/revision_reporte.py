from datetime import date, datetime
from typing import Literal

from pydantic import (
    BaseModel,
    Field,
    field_validator,
    model_validator,
)


EstadoRevision = Literal[
    "Pendiente",
    "Aprobado",
    "Rechazado",
]

DecisionRevision = Literal[
    "Aprobado",
    "Rechazado",
]


class RevisionReporteUpdate(BaseModel):
    estado_revision: DecisionRevision

    observacion_revision: str | None = Field(
        default=None,
        max_length=1000,
    )

    @field_validator(
        "observacion_revision",
        mode="before",
    )
    @classmethod
    def limpiar_observacion(
        cls,
        valor: object,
    ) -> object:
        if not isinstance(valor, str):
            return valor

        valor_limpio = valor.strip()

        return valor_limpio or None

    @model_validator(mode="after")
    def validar_rechazo(
        self,
    ) -> "RevisionReporteUpdate":
        if (
            self.estado_revision == "Rechazado"
            and self.observacion_revision is None
        ):
            raise ValueError(
                "Debes registrar una observación "
                "para rechazar el reporte."
            )

        return self


class ReporteAdminResumen(BaseModel):
    id: int
    codigo: str
    titulo: str
    estado: str
    estado_revision: EstadoRevision
    nombre_mascota: str | None
    especie: str
    ubicacion_extravio: str
    fecha_extravio: date
    fecha_creacion: datetime
    fecha_revision: datetime | None


class ReporteAdminDetalle(BaseModel):
    id: int
    codigo: str
    titulo: str
    descripcion: str
    tipo: str
    estado: str
    estado_revision: EstadoRevision

    ubicacion_extravio: str
    fecha_extravio: date
    fecha_creacion: datetime

    fecha_revision: datetime | None
    observacion_revision: str | None

    nombre_mascota: str | None
    especie: str
    raza: str | None
    color: str
    tamano: str
    edad_aproximada: int | None
    senas_particulares: str | None


class RevisionReporteOut(BaseModel):
    id: int
    codigo: str
    estado_revision: EstadoRevision
    fecha_revision: datetime
    observacion_revision: str | None
    mensaje: str