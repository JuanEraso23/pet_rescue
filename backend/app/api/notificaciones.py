# ============================================================
# Pet Rescue - Endpoints: Notificaciones de Coincidencias (HU19)
# ============================================================
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.reporte import Reporte
from app.models.notificacion_coincidencia import NotificacionCoincidencia
from app.schemas.notificacion_coincidencia import NotificacionOut, NotificacionLeidaOut
from app.services.coincidencias_service import buscar_y_crear_coincidencias

router = APIRouter(
    prefix="/reportes",
    tags=["Notificaciones (HU19)"],
)


@router.post("/{reporte_id}/buscar-coincidencias")
def disparar_busqueda_coincidencias(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    # 1. Verificar que el reporte existe
    reporte = db.get(Reporte, reporte_id)
    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    # 2. Ejecutar el servicio
    buscar_y_crear_coincidencias(db, reporte_id)

    return {
        "mensaje": "Búsqueda de coincidencias ejecutada correctamente.",
        "reporte_id": reporte_id,
    }


@router.get("/{reporte_id}/notificaciones", response_model=list[NotificacionOut])
def consultar_notificaciones(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    # 1. Verificar que el reporte existe
    reporte = db.get(Reporte, reporte_id)
    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    # 2. Buscar notificaciones
    notificaciones = db.execute(
        select(NotificacionCoincidencia)
        .where(NotificacionCoincidencia.reporte_id == reporte_id)
        .order_by(NotificacionCoincidencia.fecha_creacion.desc())
    ).scalars().all()

    return notificaciones


@router.patch("/{reporte_id}/notificaciones/{notificacion_id}/leida", response_model=NotificacionLeidaOut)
def marcar_notificacion_leida(
    reporte_id: int,
    notificacion_id: int,
    db: Session = Depends(get_db),
):
    # 1. Buscar la notificación que pertenezca al reporte
    notificacion = db.execute(
        select(NotificacionCoincidencia).where(
            NotificacionCoincidencia.id == notificacion_id,
            NotificacionCoincidencia.reporte_id == reporte_id,
        )
    ).scalar_one_or_none()

    if notificacion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notificación no encontrada para este reporte.",
        )

    # 2. Marcar como leída
    try:
        notificacion.leida = True
        db.commit()
        db.refresh(notificacion)
        
        return {
            "id": notificacion.id,
            "leida": notificacion.leida,
            "mensaje": "Notificación marcada como leída."
        }
    except Exception as error:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible marcar la notificación como leída.",
        ) from error