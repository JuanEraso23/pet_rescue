# ============================================================
# Pet Rescue - Schemas Pydantic: NotificacionCoincidencia (HU19)
# ============================================================
from datetime import datetime
from pydantic import BaseModel, ConfigDict


class NotificacionOut(BaseModel):
    id: int
    reporte_id: int
    reporte_coincidente_id: int
    mensaje: str
    leida: bool
    fecha_creacion: datetime

    model_config = ConfigDict(from_attributes=True)


class NotificacionLeidaOut(BaseModel):
    id: int
    leida: bool
    mensaje: str