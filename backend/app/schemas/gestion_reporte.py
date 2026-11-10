from datetime import datetime
from typing import Literal

from pydantic import (
    BaseModel,
    Field,
    field_validator,
    model_validator,
)


EstadoGestion = Literal[
    "Vigente",
    "Duplicado",
    "Desactualizado",
]


class GestionReporteUpdate(BaseModel):
    estado_gestion: EstadoGestion

    reporte_principal_id: int | None = Field(
        default=None,
        ge=1,
    )

    motivo_gestion: str | None = Field(
        default=None,
        max_length=1000,
    )

    @field_validator(
        "motivo_gestion",
        mode="before",
    )
    @classmethod
    def limpiar_motivo(
        cls,
        valor: object,
    ) -> object:
        if not isinstance(valor, str):
            return valor

        valor_limpio = valor.strip()

        return valor_limpio or None

    @model_validator(mode="after")
    def validar_gestion(
        self,
    ) -> "GestionReporteUpdate":
        if self.estado_gestion == "Duplicado":
            if self.reporte_principal_id is None:
                raise ValueError(
                    "Debes seleccionar el reporte "
                    "principal cuando marcas un "
                    "reporte como duplicado."
                )

            if self.motivo_gestion is None:
                raise ValueError(
                    "Debes registrar el motivo de "
                    "la duplicidad."
                )

        if (
            self.estado_gestion == "Desactualizado"
            and self.motivo_gestion is None
        ):
            raise ValueError(
                "Debes registrar el motivo por el "
                "que el reporte está desactualizado."
            )

        if (
            self.estado_gestion != "Duplicado"
            and self.reporte_principal_id is not None
        ):
            raise ValueError(
                "El reporte principal solo se "
                "permite para reportes duplicados."
            )

        return self


class ReportePrincipalResumen(BaseModel):
    id: int
    codigo: str
    titulo: str
    estado: str
    estado_revision: str
    estado_gestion: EstadoGestion
    nombre_mascota: str | None
    especie: str


class GestionReporteOut(BaseModel):
    id: int
    codigo: str
    estado_gestion: EstadoGestion

    reporte_principal_id: int | None
    codigo_reporte_principal: str | None

    motivo_gestion: str | None
    fecha_gestion: datetime | None

    mensaje: str