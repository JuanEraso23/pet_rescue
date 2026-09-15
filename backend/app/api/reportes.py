from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.database.connection import get_db
from app.models.mascota import Mascota
from app.models.reporte import Reporte
from app.schemas.reporte import ReporteCreate


router = APIRouter(
    prefix="/reportes",
    tags=["Reportes"],
)


def generar_codigo(db: Session) -> str:
    ultimo_id = db.execute(
        select(Reporte.id).order_by(
            Reporte.id.desc()
        )
    ).scalar()

    consecutivo = (ultimo_id or 0) + 1

    return f"PR-{consecutivo:04d}"


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
)
def crear_reporte(
    datos: ReporteCreate,
    db: Session = Depends(get_db),
):
    mascota = Mascota(
        nombre=datos.nombre,
        especie=datos.especie,
        raza=datos.raza,
        color=datos.color,
        tamano=datos.tamano,
        edad_aproximada=datos.edad_aproximada,
        senas_particulares=datos.senas_particulares,
    )

    try:
        db.add(mascota)
        db.flush()

        reporte = Reporte(
            codigo=generar_codigo(db),
            mascota_id=mascota.id,
            titulo=datos.titulo,
            descripcion=datos.descripcion,
            tipo="Perdida",
            estado="Activo",
            ubicacion_extravio=datos.ubicacion_extravio,
            fecha_extravio=datos.fecha_extravio,
            hora_extravio=datos.hora_extravio,
        )

        db.add(reporte)
        db.commit()
        db.refresh(reporte)

        return {
            "id": reporte.id,
            "codigo": reporte.codigo,
            "estado": reporte.estado,
            "fecha_creacion": reporte.fecha_creacion,
            "mensaje": "Reporte registrado correctamente",
        }

    except Exception as error:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible registrar el reporte.",
        ) from error


@router.get("/{reporte_id}")
def consultar_reporte(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    consulta = (
        select(Reporte)
        .options(joinedload(Reporte.mascota))
        .where(
            Reporte.id == reporte_id
        )
    )

    reporte = db.execute(
        consulta
    ).scalar_one_or_none()

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    return {
        "id": reporte.id,
        "codigo": reporte.codigo,
        "titulo": reporte.titulo,
        "descripcion": reporte.descripcion,
        "tipo": reporte.tipo,
        "estado": reporte.estado,
        "ubicacion_extravio": reporte.ubicacion_extravio,
        "fecha_extravio": reporte.fecha_extravio,
        "hora_extravio": reporte.hora_extravio,
        "fecha_creacion": reporte.fecha_creacion,
        "mascota": {
            "id": reporte.mascota.id,
            "nombre": reporte.mascota.nombre,
            "especie": reporte.mascota.especie,
            "raza": reporte.mascota.raza,
            "color": reporte.mascota.color,
            "tamano": reporte.mascota.tamano,
            "edad_aproximada":
                reporte.mascota.edad_aproximada,
            "senas_particulares":
                reporte.mascota.senas_particulares,
        },
    }