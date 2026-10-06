# ============================================================
# Pet Rescue - Schemas Pydantic: ContactoReporte (HU5)
# ============================================================
from datetime import datetime
from typing import Literal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    field_validator,
)


class ContactoCreate(BaseModel):
    tipo_contacto: Literal[
        "Telefono",
        "Correo",
    ]

    valor_contacto: str = Field(
        min_length=1,
        max_length=150,
    )

    mostrar_publicamente: bool = True

    @field_validator("valor_contacto")
    @classmethod
    def validar_valor(
        cls,
        valor: str,
    ) -> str:
        valor_limpio = valor.strip()

        if not valor_limpio:
            raise ValueError(
                "El valor de contacto no puede estar vacío."
            )

        return valor_limpio


class ContactoOut(BaseModel):
    id: int
    reporte_id: int
    tipo_contacto: str
    valor_contacto: str
    mostrar_publicamente: bool
    fecha_creacion: datetime

    model_config = ConfigDict(
        from_attributes=True,
    )


class ContactoPublico(BaseModel):
    tipo_contacto: str
    valor_contacto: str
    mostrar_publicamente: bool
