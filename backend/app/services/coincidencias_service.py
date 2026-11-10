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

        # Comparar raza parcial
        if (reporte_base.mascota.raza and otro.mascota.raza and 
            reporte_base.mascota.raza.lower() in otro.mascota.raza.lower()):
            coincidencias += 1
            
        # Comparar color parcial
        if (reporte_base.mascota.color and otro.mascota.color and 
            reporte_base.mascota.color.lower() in otro.mascota.color.lower()):
            coincidencias += 1
            
        # Comparar tamaño exacto
        if (reporte_base.mascota.tamano and otro.mascota.tamano and 
            reporte_base.mascota.tamano == otro.mascota.tamano):
            coincidencias += 1
            
        # Comparar ubicación parcial
        if (reporte_base.ubicacion_extravio and otro.ubicacion_extravio and 
            reporte_base.ubicacion_extravio.lower() in otro.ubicacion_extravio.lower()):
            coincidencias += 1

        # Regla: especie exacta (ya filtrada arriba) + al menos 2 adicionales
        if coincidencias >= 2:
            # Evitar duplicados
            existente = db.execute(
                select(NotificacionCoincidencia).where(
                    or_(
                        and_(NotificacionCoincidencia.reporte_id == reporte_id, NotificacionCoincidencia.reporte_coincidente_id == otro.id),
                        and_(NotificacionCoincidencia.reporte_id == otro.id, NotificacionCoincidencia.reporte_coincidente_id == reporte_id)
                    )
                )
            ).scalar_one_or_none()

            if not existente:
                mensaje = f"Posible coincidencia encontrada con el reporte {otro.codigo} ({otro.mascota.nombre or 'Sin nombre'})."
                
                # Crear notificación para el reporte base
                notificacion = NotificacionCoincidencia(
                    reporte_id=reporte_id,
                    reporte_coincidente_id=otro.id,
                    mensaje=mensaje
                )
                db.add(notificacion)
                
                # Crear notificación inversa para el otro reporte
                notificacion_inversa = NotificacionCoincidencia(
                    reporte_id=otro.id,
                    reporte_coincidente_id=reporte_id,
                    mensaje=f"Posible coincidencia encontrada con el reporte {reporte_base.codigo} ({reporte_base.mascota.nombre or 'Sin nombre'})."
                )
                db.add(notificacion_inversa)
                
    try:
        db.commit()
    except Exception as e:
        db.rollback()
        print("ERROR AL CREAR COINCIDENCIAS:", repr(e))