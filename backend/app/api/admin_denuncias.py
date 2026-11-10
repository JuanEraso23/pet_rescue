from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Literal

from app.database.connection import get_db
from app.models.denuncia_reporte import DenunciaReporte
from app.models.reporte import Reporte
from pydantic import BaseModel, Field, field_validator
from typing import Optional

router = APIRouter(
    prefix="/admin/denuncias",
    tags=["Admin - Denuncias (HU21)"],
)

class DenunciaAdminUpdate(BaseModel):
    estado: Literal["Aprobada", "Rechazada"]
    observacion_admin: Optional[str] = Field(default=None, max_length=500)

    @field_validator("observacion_admin")
    @classmethod
    def limpiar_observacion(cls, valor):
        if valor is not None:
            return valor.strip()
        return valor

@router.get("")
def listar_denuncias(
    estado: Optional[str] = None,
    db: Session = Depends(get_db),
):
    consulta = select(DenunciaReporte).options(joinedload(DenunciaReporte.reporte))
    if estado is not None:
        consulta = consulta.where(DenunciaReporte.estado == estado)
    
    consulta = consulta.order_by(DenunciaReporte.fecha_creacion.desc())
    denuncias = db.execute(consulta).scalars().all()

    return [
        {
            "id": d.id,
            "reporte_id": d.reporte_id,
            "reporte_codigo": d.reporte.codigo if d.reporte else None,
            "reporte_titulo": d.reporte.titulo if d.reporte else None,
            "motivo": d.motivo,
            "descripcion": d.descripcion,
            "estado": d.estado,
            "fecha_creacion": d.fecha_creacion,
        }
        for d in denuncias
    ]

@router.get("/{denuncia_id}")
def consultar_denuncia(
    denuncia_id: int,
    db: Session = Depends(get_db),
):
    denuncia = db.execute(
        select(DenunciaReporte)
        .options(joinedload(DenunciaReporte.reporte))
        .where(DenunciaReporte.id == denuncia_id)
    ).scalar_one_or_none()

    if denuncia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Denuncia no encontrada.",
        )

    return {
        "id": denuncia.id,
        "reporte_id": denuncia.reporte_id,
        "reporte_codigo": denuncia.reporte.codigo if denuncia.reporte else None,
        "reporte_titulo": denuncia.reporte.titulo if denuncia.reporte else None,
        "motivo": denuncia.motivo,
        "descripcion": denuncia.descripcion,
        "estado": denuncia.estado,
        "fecha_creacion": denuncia.fecha_creacion,
        "observacion_admin": denuncia.observacion_admin,
        "fecha_revision": denuncia.fecha_revision,
    }

@router.patch("/{denuncia_id}")
def validar_denuncia(
    denuncia_id: int,
    datos: DenunciaAdminUpdate,
    db: Session = Depends(get_db),
):
    denuncia = db.execute(
        select(DenunciaReporte)
        .options(joinedload(DenunciaReporte.reporte))
        .where(DenunciaReporte.id == denuncia_id)
    ).scalar_one_or_none()

    if denuncia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Denuncia no encontrada.",
        )

    if denuncia.estado != "Pendiente":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="La denuncia ya fue revisada.",
        )

    try:
        denuncia.estado = datos.estado
        denuncia.observacion_admin = datos.observacion_admin
        denuncia.fecha_revision = datetime.now()

        # HU21 dice: si se aprueba, cerrar el reporte (trazabilidad)
        if datos.estado == "Aprobada" and denuncia.reporte:
            if denuncia.reporte.estado not in ["Cerrado", "Encontrado"]:
                denuncia.reporte.estado = "Cerrado"

        db.commit()
        db.refresh(denuncia)

        return {
            "id": denuncia.id,
            "estado": denuncia.estado,
            "mensaje": "Denuncia revisada correctamente.",
        }
    except Exception as error:
        db.rollback()
        print("ERROR AL VALIDAR DENUNCIA:", repr(error))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible validar la denuncia.",
        ) from error
