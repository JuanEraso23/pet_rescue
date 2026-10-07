# ============================================================
# Pet Rescue - API: Avistamientos (HU10)
# ============================================================
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.avistamiento import Avistamiento
from app.models.reporte import Reporte
from app.schemas.avistamiento import (
    AvistamientoCreate,
    AvistamientoOut,
)


router = APIRouter(
    prefix="/reports",
    tags=["Avistamientos"],
)


def obtener_reporte(
    reporte_id: int,
    db: Session,
) -> Reporte:
    reporte = db.execute(
        select(Reporte).where(
            Reporte.id == reporte_id
        )
    ).scalar_one_or_none()

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    return reporte


@router.post(
    "/{reporte_id}/avistamientos",
    response_model=AvistamientoOut,
    status_code=status.HTTP_201_CREATED,
)
def registrar_avistamiento(
    reporte_id: int,
    datos: AvistamientoCreate,
    db: Session = Depends(get_db),
):
    obtener_reporte(
        reporte_id=reporte_id,
        db=db,
    )

    avistamiento = Avistamiento(
        reporte_id=reporte_id,
        descripcion=datos.descripcion,
        ubicacion_aproximada=datos.ubicacion_aproximada,
        fecha_avistamiento=datos.fecha_avistamiento,
        hora_avistamiento=datos.hora_avistamiento,
    )

    try:
        db.add(avistamiento)
        db.commit()
        db.refresh(avistamiento)

        return avistamiento

    except Exception as error:
        db.rollback()

        print("ERROR AL GUARDAR AVISTAMIENTO:")
        print(repr(error))

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible guardar el avistamiento.",
        ) from error


@router.get(
    "/{reporte_id}/avistamientos",
    response_model=list[AvistamientoOut],
)
def consultar_avistamientos(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    obtener_reporte(
        reporte_id=reporte_id,
        db=db,
    )

    consulta = (
        select(Avistamiento)
        .where(Avistamiento.reporte_id == reporte_id)
        .order_by(
            Avistamiento.fecha_avistamiento.desc(),
            Avistamiento.fecha_creacion.desc(),
        )
    )

    avistamientos = db.execute(
        consulta
    ).scalars().all()

    return avistamientos
