# ============================================================
# Pet Rescue - Modelo SQLAlchemy: DenunciaReporte (HU20)
# ============================================================
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.connection import Base


class DenunciaReporte(Base):
    __tablename__ = "denuncias_reporte"

    id = Column(Integer, primary_key=True, index=True)
    reporte_id = Column(Integer, ForeignKey("reportes.id", ondelete="CASCADE"), nullable=False, index=True)
    motivo = Column(String(30), nullable=False)
    descripcion = Column(Text)
    estado = Column(String(20), nullable=False, default="Pendiente", index=True)
    fecha_creacion = Column(DateTime, nullable=False, server_default=func.now())
    fecha_revision = Column(DateTime)
    observacion_admin = Column(Text)

    # Relación con Reporte
    reporte = relationship("Reporte", backref="denuncias")

    def __repr__(self):
        return f"<DenunciaReporte id={self.id} motivo={self.motivo} estado={self.estado}>"
