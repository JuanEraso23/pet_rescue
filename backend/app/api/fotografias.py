from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.fotografia_reporte import FotografiaReporte
from app.models.reporte import Reporte


router = APIRouter(
    prefix="/reportes",
    tags=["Fotografias"],
)

TIPOS_PERMITIDOS = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}

TAMANO_MAXIMO = 5 * 1024 * 1024

CARPETA_UPLOADS = (
    Path(__file__).resolve().parents[2]
    / "uploads"
    / "reportes"
)

CARPETA_UPLOADS.mkdir(
    parents=True,
    exist_ok=True,
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


def crear_respuesta(
    fotografia: FotografiaReporte,
) -> dict:
    return {
        "id": fotografia.id,
        "reporte_id": fotografia.reporte_id,
        "nombre_archivo": fotografia.nombre_archivo,
        "url": f"/uploads/reportes/{fotografia.nombre_archivo}",
        "tipo_mime": fotografia.tipo_mime,
        "tamano_bytes": fotografia.tamano_bytes,
        "fecha_creacion": fotografia.fecha_creacion,
    }


@router.post(
    "/{reporte_id}/fotografias",
    status_code=status.HTTP_201_CREATED,
)
async def cargar_fotografia(
    reporte_id: int,
    archivo: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    obtener_reporte(
        reporte_id=reporte_id,
        db=db,
    )

    if archivo.content_type not in TIPOS_PERMITIDOS:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                "Formato no permitido. "
                "La fotografia debe ser JPG, PNG o WebP."
            ),
        )

    contenido = await archivo.read()

    if not contenido:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="El archivo esta vacio.",
        )

    if len(contenido) > TAMANO_MAXIMO:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="La fotografia no puede superar los 5 MB.",
        )

    extension = TIPOS_PERMITIDOS[archivo.content_type]
    nombre_unico = f"{uuid4().hex}{extension}"
    ruta_completa = CARPETA_UPLOADS / nombre_unico

    fotografia = FotografiaReporte(
        reporte_id=reporte_id,
        nombre_archivo=nombre_unico,
        ruta_archivo=str(ruta_completa),
        tipo_mime=archivo.content_type,
        tamano_bytes=len(contenido),
    )

    try:
        ruta_completa.write_bytes(contenido)

        db.add(fotografia)
        db.commit()
        db.refresh(fotografia)

        return crear_respuesta(fotografia)

    except Exception as error:
        db.rollback()

        if ruta_completa.exists():
            ruta_completa.unlink()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible guardar la fotografia.",
        ) from error

    finally:
        await archivo.close()


@router.get(
    "/{reporte_id}/fotografias",
)
def consultar_fotografias(
    reporte_id: int,
    db: Session = Depends(get_db),
):
    obtener_reporte(
        reporte_id=reporte_id,
        db=db,
    )

    consulta = (
        select(FotografiaReporte)
        .where(
            FotografiaReporte.reporte_id == reporte_id
        )
        .order_by(
            FotografiaReporte.fecha_creacion.asc()
        )
    )

    fotografias = db.execute(
        consulta
    ).scalars().all()

    return [
        crear_respuesta(fotografia)
        for fotografia in fotografias
    ]