# ============================================================
# Pet Rescue - Esquema Pydantic: FotografiaReporte
# ============================================================

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class FotografiaReporteOut(BaseModel):
    id: int
    reporte_id: int
    nombre_archivo: str
    url: str
    tipo_mime: str
    tamano_bytes: int = Field(
        gt=0,
        le=5242880,
    )
    fecha_creacion: datetime

    model_config = ConfigDict(
        from_attributes=True,
    )