# ============================================================
# Pet Rescue - Servicio de Coincidencias (HU19)
# ============================================================
from sqlalchemy.orm import Session
from sqlalchemy import select, or_, and_
from app.models.reporte import Reporte
from app.models.notificacion_coincidencia import NotificacionCoincidencia


def buscar_y_crear_coincidencias(db: Session, reporte_id: int):
    # 1. Obtener el reporte base
    reporte_base = db.get(Reporte, reporte_id)
    if not reporte_base or reporte_base.estado != "Activo":
        return

    # 2. Traer todos los reportes activos que NO sean el mismo
    otros_reportes = db.execute(
        select(Reporte).where(
            Reporte.estado == "Activo",
            Reporte.id != reporte_id,
            Reporte.mascota.has(Reporte.mascota.property.mapper.class_.especie == reporte_base.mascota.especie)
        )
    ).scalars().all()

    for otro in otros_reportes:
        coincidencias = 0

        raza_match = (
            reporte_base.mascota.raza
            and otro.mascota.raza
            and (
                reporte_base.mascota.raza.lower() in otro.mascota.raza.lower()
                or otro.mascota.raza.lower() in reporte_base.mascota.raza.lower()
            )
        )
        if raza_match:
            coincidencias += 1

        color_match = (
            reporte_base.mascota.color
            and otro.mascota.color
            and (
                reporte_base.mascota.color.lower() in otro.mascota.color.lower()
                or otro.mascota.color.lower() in reporte_base.mascota.color.lower()
            )
        )
        if color_match:
            coincidencias += 1

        # Comparar tamaño exacto
        if (
            reporte_base.mascota.tamano
            and otro.mascota.tamano
            and reporte_base.mascota.tamano == otro.mascota.tamano
        ):
            coincidencias += 1

        ubicacion_match = (
            reporte_base.ubicacion_extravio
            and otro.ubicacion_extravio
            and (
                reporte_base.ubicacion_extravio.lower()
                in otro.ubicacion_extravio.lower()
                or otro.ubicacion_extravio.lower()
                in reporte_base.ubicacion_extravio.lower()
            )
        )
        if ubicacion_match:
            coincidencias += 1

        # Regla: especie exacta (ya filtrada arriba) + al menos 2 adicionales
        if coincidencias >= 2:
            notificacion_existente = db.execute(
                select(NotificacionCoincidencia).where(
                    or_(
                        and_(
                            NotificacionCoincidencia.reporte_id == reporte_base.id,
                            NotificacionCoincidencia.reporte_coincidente_id == otro.id,
                        ),
                        and_(
                            NotificacionCoincidencia.reporte_id == otro.id,
                            NotificacionCoincidencia.reporte_coincidente_id
                            == reporte_base.id,
                        ),
                    )
                )
            ).scalars().first()

            if not notificacion_existente:
                notificacion = NotificacionCoincidencia(
                    reporte_id=reporte_base.id,
                    reporte_coincidente_id=otro.id,
                    mensaje=(
                        f"Posible coincidencia encontrada: "
                        f"{otro.codigo} - {otro.titulo}"
                    ),
                )
                db.add(notificacion)

    try:
        db.commit()
    except Exception as e:
        db.rollback()
        print("ERROR AL CREAR COINCIDENCIAS:", repr(e))