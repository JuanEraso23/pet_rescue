from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload
import re

from app.database.connection import get_db
from app.models.mascota import Mascota
from app.models.reporte import Reporte
from app.models.contacto_reporte import ContactoReporte
from app.schemas.reporte import ReporteCreate
from app.schemas.contacto_reporte import ContactoCreate


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

        print("ERROR AL REGISTRAR REPORTE:")
        print(repr(error))

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


# ============================================================
# HU5 - Medio de contacto seguro
# ============================================================

@router.post(
    "/{reporte_id}/contacto",
    status_code=status.HTTP_201_CREATED,
)
def crear_contacto(
    reporte_id: int,
    datos: ContactoCreate,
    db: Session = Depends(get_db),
):
    # 1. Verificar que el reporte existe
    reporte = db.get(Reporte, reporte_id)

    if reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reporte no encontrado.",
        )

    # 2. Verificar que no exista ya un contacto
    existente = db.execute(
        select(ContactoReporte).where(
            ContactoReporte.reporte_id == reporte_id
        )
    ).scalar_one_or_none()

    if existente is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este reporte ya tiene un contacto registrado.",
        )

    # 3. Validar formato segun tipo
    valor = datos.valor_contacto

    if datos.tipo_contacto == "Telefono":
        # Permitir solo digitos, espacios, guiones y + (formato flexible)
        valor_limpio = valor.replace(" ", "").replace("-", "").replace("+", "")

        if not valor_limpio.isdigit():
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El telefono solo puede contener digitos.",
            )

        if not (7 <= len(valor_limpio) <= 15):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El telefono debe tener entre 7 y 15 digitos.",
            )
    elif datos.tipo_contacto == "Correo":
        patron = r"^[\w\.\-]+@[\w\.\-]+\.\w+$"

        if not re.match(patron, valor):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El correo electronico no tiene un formato valido.",
            )

    # 4. Guardar
    contacto = ContactoReporte(
        reporte_id=reporte_id,
        tipo_contacto=datos.tipo_contacto,
        valor_contacto=valor,
        mostrar_publicamente=datos.mostrar_publicamente,
    )

    try:
        db.add(contacto)
        db.commit()
        db.refresh(contacto)

        return {
            "id": contacto.id,
            "reporte_id": contacto.reporte_id,
            "tipo_contacto": contacto.tipo_contacto,
            "valor_contacto": contacto.valor_contacto,
            "mostrar_publicamente": contacto.mostrar_publicamente,
            "fecha_creacion": contacto.fecha_creacion,
        }

    except Exception as error:
        db.rollback()

        print("ERROR AL GUARDAR CONTACTO:")
        print(repr(error))

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No fue posible guardar el contacto.",
        ) from error


@router.get("/{reporte_id}/contacto")
def consultar_contacto(
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

    # 2. Buscar el contacto
    contacto = db.execute(
        select(ContactoReporte).where(
            ContactoReporte.reporte_id == reporte_id
        )
    ).scalar_one_or_none()

    if contacto is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Este reporte no tiene contacto registrado.",
        )

    # 3. Aplicar privacidad
    if contacto.mostrar_publicamente:
        valor_mostrado = contacto.valor_contacto
    else:
        valor_mostrado = "Contacto privado"

    return {
        "tipo_contacto": contacto.tipo_contacto,
        "valor_contacto": valor_mostrado,
        "mostrar_publicamente": contacto.mostrar_publicamente,
    }