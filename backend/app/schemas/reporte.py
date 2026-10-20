from datetime import date, datetime, time
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class ReporteCreate(BaseModel):
    titulo: str = Field(min_length=3, max_length=200)
    descripcion: str = Field(min_length=10)
    especie: Literal["Perro", "Gato", "Ave", "Roedor", "Otro"]
    nombre: str | None = Field(default=None, max_length=100)
    raza: str | None = Field(default=None, max_length=100)
    color: str = Field(min_length=2, max_length=50)
    tamano: Literal["Pequeño", "Mediano", "Grande"]
    edad_aproximada: int | None = Field(default=None, ge=0)
    senas_particulares: str | None = None
    ubicacion_extravio: str = Field(min_length=3, max_length=200)
    fecha_extravio: date
    hora_extravio: time | None = None

    @field_validator("titulo", "descripcion", "color", "ubicacion_extravio")
    @classmethod
    def validar_texto(cls, valor: str) -> str:
        valor_limpio = valor.strip()
        if not valor_limpio:
            raise ValueError("El campo no puede contener solo espacios.")
        return valor_limpio

    @field_validator("fecha_extravio")
    @classmethod
    def validar_fecha(cls, valor: date) -> date:
        if valor > date.today():
            raise ValueError("La fecha del extravío no puede ser futura.")
        return valor


class ReporteOut(BaseModel):
    id: int
    codigo: str
    estado: str
    fecha_creacion: datetime
    mensaje: str
    model_config = ConfigDict(from_attributes=True)


class ReporteUpdate(BaseModel):
    titulo: str | None = Field(default=None, min_length=5, max_length=200)
    descripcion: str | None = Field(default=None, min_length=10)
    nombre_mascota: str | None = Field(default=None, max_length=100)
    especie: str | None = Field(default=None, max_length=50)
    raza: str | None = Field(default=None, max_length=100)
    color: str | None = Field(default=None, max_length=50)
    tamano: str | None = Field(default=None, max_length=20)
    edad_aproximada: int | None = Field(default=None, ge=0)
    senas_particulares: str | None = None
    ubicacion_extravio: str | None = Field(default=None, min_length=3, max_length=200)
    fecha_extravio: date | None = None
    hora_extravio: time | None = None

    @field_validator("titulo", "descripcion", "ubicacion_extravio", mode="before")
    @classmethod
    def limpiar_textos(cls, valor):
        if isinstance(valor, str):
            return valor.strip()
        return valor

    @field_validator("fecha_extravio")
    @classmethod
    def validar_fecha_update(cls, valor):
        if valor is not None and valor > date.today():
            raise ValueError("La fecha de extravío no puede ser futura.")
        return valor

    @model_validator(mode="after")
    def validator_al_menos_un_cambio(self):
        if not self.model_fields_set:
            raise ValueError("Debes enviar al menos un campo para actualizar.")
        return self