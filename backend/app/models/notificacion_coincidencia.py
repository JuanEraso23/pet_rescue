# ============================================================
# Pet Rescue - Modelo SQLAlchemy: NotificacionCoincidencia (HU19)
# ============================================================
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, func, UniqueConstraint, CheckConstraint
from sqlalchemy.orm import relationship
from app.database.connection import Base


class NotificacionCoincidencia(Base):
    __tablename__ = "notificaciones_coincidencia"

    id = Column(Integer, primary_key=True, index=True)
    reporte_id = Column(Integer, ForeignKey("reportes.id", ondelete="CASCADE"), nullable=False, index=True)
    reporte_coincidente_id = Column(Integer, ForeignKey("reportes.id", ondelete="CASCADE"), nullable=False)
    mensaje = Column(String(300), nullable=False)
    leida = Column(Boolean, nullable=False, default=False)
    fecha_creacion = Column(DateTime, nullable=False, server_default=func.now())

    # Restricciones a nivel de base de datos
    __table_args__ = (
        UniqueConstraint("reporte_id", "reporte_coincidente_id", name="ux_notificacion_pareja"),
        CheckConstraint("reporte_id <> reporte_coincidente_id", name="ck_notificacion_reportes_distintos"),
    )

    # Relaciones
    reporte = relationship("Reporte", foreign_keys=[reporte_id], backref="notificaciones")
    reporte_coincidente = relationship("Reporte", foreign_keys=[reporte_coincidente_id])

    def __repr__(self):
        return f"<Notificacion id={self.id} reporte={self.reporte_id} leida={self.leida}>"
