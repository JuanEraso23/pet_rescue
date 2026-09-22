from datetime import date, datetime, time
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ReporteCreate(BaseModel):
    titulo: str = Field(
        min_length=3,
        max_length=200,
    )

    descripcion: str = Field(
        min_length=10,
    )

    especie: Literal[
        "Perro",
        "Gato",
        "Ave",
        "Roedor",
        "Otro",
    ]

    nombre: str | None = Field(
        default=None,
        max_length=100,
    )

    raza: str | None = Field(
        default=None,
        max_length=100,
    )

    color: str = Field(
        min_length=2,
        max_length=50,
    )

    tamano: Literal[
        "Pequeño",
        "Mediano",
        "Grande",
    ]

    edad_aproximada: int | None = Field(
        default=None,
        ge=0,
    )

    senas_particulares: str | None = None

    ubicacion_extravio: str = Field(
        min_length=3,
        max_length=200,
    )

    fecha_extravio: date
    hora_extravio: time | None = None

    @field_validator(
        "titulo",
        "descripcion",
        "color",
        "ubicacion_extravio",
    )
    @classmethod
    def validar_texto(
        cls,
        valor: str,
    ) -> str:
        valor_limpio = valor.strip()

        if not valor_limpio:
            raise ValueError(
                "El campo no puede contener solo espacios."
            )

        return valor_limpio

    @field_validator("fecha_extravio")
    @classmethod
    def validar_fecha(
        cls,
        valor: date,
    ) -> date:
        if valor > date.today():
            raise ValueError(
                "La fecha del extravío no puede ser futura."
            )

        return valor


class ReporteOut(BaseModel):
    id: int
    codigo: str
    estado: str
    fecha_creacion: datetime
    mensaje: str

    model_config = ConfigDict(
        from_attributes=True,
    )