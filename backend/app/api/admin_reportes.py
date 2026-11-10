from datetime import datetime
from typing import Literal

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
)
from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session, joinedload

from app.database.connection import get_db
from app.models.reporte import Reporte
from app.schemas.gestion_reporte import (
    GestionReporteOut,
    GestionReporteUpdate,
    ReportePrincipalResumen,
)
from app.schemas.revision_reporte import (
    ReporteAdminDetalle,
    ReporteAdminResumen,
    RevisionReporteOut,
    RevisionReporteUpdate,
)


router = APIRouter(
    prefix="/admin/reportes",
    tags=["Administración de reportes"],
)


@router.get(
    "",
    response_model=list[ReporteAdminResumen],
)
def listar_reportes_administrativos(
    estado_revision: Literal[
        "Pendiente",
        "Aprobado",
        "Rechazado",
    ]
    | None = None,
    db: Session = Depends(get_db),
):
    consulta = (
        select(Reporte)
        .options(
            joinedload(Reporte.mascota),
            joinedload(Reporte.reporte_principal),
        )
        .order_by(
            Reporte.fecha_creacion.desc(),
            Reporte.id.desc(),
        )
    )

    if estado_revision is not None:
        consulta = consulta.where(
            Reporte.estado_revision == estado_revision,
        )

    reportes = db.execute(
        consulta
    ).scalars().unique().all()

    return [
        {
            "id": reporte.id,
            "codigo": reporte.codigo,
            "titulo": reporte.titulo,
            "estado": reporte.estado,
            "estado_revision": (
                reporte.estado_revision
            ),
            "estado_gestion": reporte.estado_gestion,
            "reporte_principal_id": (
                reporte.reporte_principal_id
            ),
            "codigo_reporte_principal": (
                reporte.reporte_principal.codigo
                if reporte.reporte_principal is not None
                else None
            ),
            "fecha_gestion": reporte.fecha_gestion,
            "nombre_mascota": (
                reporte.mascota.nombre
            ),
            "especie": reporte.mascota.especie,
            "ubicacion_extravio": (
                reporte.ubicacion_extravio
            ),
            "fecha_extravio": (
                reporte.fecha_extravio
            ),
            "fecha_creacion": (
                reporte.fecha_creacion
            ),
            "fecha_revision": (
                reporte.fecha_revision
            ),
        }
        for reporte in reportes
    ]


@router.get(
    "/{reporte_id}",
    response_model=ReporteAdminDetalle,
)
def consultar_reporte_administrativo(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    reporte = db.execute(
        select(Reporte)
        .options(
            joinedload(Reporte.mascota),
            joinedload(Reporte.reporte_principal),
        )
        .where(
            Reporte.id == reporte_id,
        )
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
        "estado_revision": reporte.estado_revision,
        "estado_gestion": reporte.estado_gestion,
        "reporte_principal_id": (
            reporte.reporte_principal_id
        ),
        "codigo_reporte_principal": (
            reporte.reporte_principal.codigo
            if reporte.reporte_principal is not None
            else None
        ),
        "motivo_gestion": reporte.motivo_gestion,
        "fecha_gestion": reporte.fecha_gestion,
        "ubicacion_extravio": (
            reporte.ubicacion_extravio
        ),
        "fecha_extravio": reporte.fecha_extravio,
        "fecha_creacion": reporte.fecha_creacion,
        "fecha_revision": reporte.fecha_revision,
        "observacion_revision": (
            reporte.observacion_revision
        ),
        "nombre_mascota": reporte.mascota.nombre,
        "especie": reporte.mascota.especie,
        "raza": reporte.mascota.raza,
        "color": reporte.mascota.color,
        "tamano": reporte.mascota.tamano,
        "edad_aproximada": (
            reporte.mascota.edad_aproximada
        ),
        "senas_particulares": (
            reporte.mascota.senas_particulares
        ),
    }


@router.get(
    "/{reporte_id}/candidatos-principales",
    response_model=list[ReportePrincipalResumen],
)
def listar_candidatos_principales(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    reporte = db.execute(
        select(Reporte).where(
            Reporte.id == reporte_id,
        )
    ).scalar_one_or_none()

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    consulta = (
        select(Reporte)
        .options(
            joinedload(Reporte.mascota),
        )
        .where(
            Reporte.id != reporte_id,
            Reporte.estado_gestion == "Vigente",
        )
        .order_by(
            Reporte.fecha_creacion.desc(),
            Reporte.id.desc(),
        )
    )

    candidatos = db.execute(
        consulta
    ).scalars().unique().all()

    return [
        {
            "id": candidato.id,
            "codigo": candidato.codigo,
            "titulo": candidato.titulo,
            "estado": candidato.estado,
            "estado_revision": (
                candidato.estado_revision
            ),
            "estado_gestion": (
                candidato.estado_gestion
            ),
            "nombre_mascota": (
                candidato.mascota.nombre
            ),
            "especie": candidato.mascota.especie,
        }
        for candidato in candidatos
    ]


@router.patch(
    "/{reporte_id}/gestion",
    response_model=GestionReporteOut,
)
def gestionar_reporte(
    reporte_id: int,
    datos: GestionReporteUpdate,
    db: Session = Depends(get_db),
):
    reporte = db.execute(
        select(Reporte)
        .options(
            joinedload(Reporte.reporte_principal),
        )
        .where(
            Reporte.id == reporte_id,
        )
    ).scalar_one_or_none()

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    reporte_principal = None

    if datos.estado_gestion == "Duplicado":
        if datos.reporte_principal_id == reporte.id:
            raise HTTPException(
                status_code=(
                    status.HTTP_422_UNPROCESSABLE_ENTITY
                ),
                detail=(
                    "Un reporte no puede marcarse "
                    "como duplicado de sí mismo."
                ),
            )

        reporte_principal = db.execute(
            select(Reporte).where(
                Reporte.id
                == datos.reporte_principal_id,
            )
        ).scalar_one_or_none()

        if reporte_principal is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=(
                    "El reporte principal "
                    "seleccionado no existe."
                ),
            )

        if (
            reporte_principal.estado_gestion
            != "Vigente"
        ):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=(
                    "El reporte principal debe "
                    "estar vigente."
                ),
            )

    try:
        if datos.estado_gestion == "Vigente":
            reporte.estado_gestion = "Vigente"
            reporte.reporte_principal_id = None
            reporte.motivo_gestion = None
            reporte.fecha_gestion = None

        elif datos.estado_gestion == "Duplicado":
            reporte.estado_gestion = "Duplicado"
            reporte.reporte_principal_id = (
                reporte_principal.id
            )
            reporte.motivo_gestion = (
                datos.motivo_gestion
            )
            reporte.fecha_gestion = datetime.now()

        else:
            reporte.estado_gestion = (
                "Desactualizado"
            )
            reporte.reporte_principal_id = None
            reporte.motivo_gestion = (
                datos.motivo_gestion
            )
            reporte.fecha_gestion = datetime.now()

        db.commit()
        db.refresh(reporte)

    except SQLAlchemyError as error:
        db.rollback()

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "No fue posible guardar la "
                "gestión administrativa."
            ),
        ) from error

    codigo_principal = (
        reporte_principal.codigo
        if reporte_principal is not None
        else None
    )

    mensajes = {
        "Vigente": (
            "El reporte fue restaurado "
            "como vigente."
        ),
        "Duplicado": (
            "El reporte fue marcado "
            "como duplicado."
        ),
        "Desactualizado": (
            "El reporte fue marcado "
            "como desactualizado."
        ),
    }

    return {
        "id": reporte.id,
        "codigo": reporte.codigo,
        "estado_gestion": reporte.estado_gestion,
        "reporte_principal_id": (
            reporte.reporte_principal_id
        ),
        "codigo_reporte_principal": (
            codigo_principal
        ),
        "motivo_gestion": reporte.motivo_gestion,
        "fecha_gestion": reporte.fecha_gestion,
        "mensaje": mensajes[
            reporte.estado_gestion
        ],
    }


@router.patch(
    "/{reporte_id}/revision",
    response_model=RevisionReporteOut,
)
def revisar_reporte(
    reporte_id: int,
    datos: RevisionReporteUpdate,
    db: Session = Depends(get_db),
):
    reporte = db.execute(
        select(Reporte).where(
            Reporte.id == reporte_id,
        )
    ).scalar_one_or_none()

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    if reporte.estado_revision != "Pendiente":
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "El reporte ya tiene una decisión "
                "administrativa registrada."
            ),
        )

    try:
        reporte.estado_revision = (
            datos.estado_revision
        )
        reporte.observacion_revision = (
            datos.observacion_revision
        )
        reporte.fecha_revision = datetime.now()

        db.commit()
        db.refresh(reporte)
    except SQLAlchemyError as error:
        db.rollback()

        raise HTTPException(
            status_code=(
                status.HTTP_500_INTERNAL_SERVER_ERROR
            ),
            detail=(
                "No fue posible guardar la "
                "revisión administrativa."
            ),
        ) from error

    mensaje = (
        "Reporte aprobado correctamente."
        if reporte.estado_revision == "Aprobado"
        else "Reporte rechazado correctamente."
    )

    return {
        "id": reporte.id,
        "codigo": reporte.codigo,
        "estado_revision": (
            reporte.estado_revision
        ),
        "fecha_revision": reporte.fecha_revision,
        "observacion_revision": (
            reporte.observacion_revision
        ),
        "mensaje": mensaje,
    }