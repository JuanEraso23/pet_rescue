# ============================================================
# Pet Rescue - Modelo SQLAlchemy: ContactoReporte (HU5)
# ============================================================
from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    DateTime,
    ForeignKey,
    func,
)
from sqlalchemy.orm import relationship

from app.database.connection import Base


class ContactoReporte(Base):
    __tablename__ = "contacto_reporte"

    id = Column(Integer, primary_key=True, index=True)
    reporte_id = Column(
        Integer,
        ForeignKey("reportes.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )
    tipo_contacto = Column(String(20), nullable=False)
    valor_contacto = Column(String(150), nullable=False)
    mostrar_publicamente = Column(Boolean, nullable=False, default=True)
    fecha_creacion = Column(DateTime, nullable=False, server_default=func.now())

    # Relación 1 a 1 con Reporte
    reporte = relationship("Reporte", back_populates="contacto")

    def __repr__(self):
        return (
            f"<ContactoReporte id={self.id} "
            f"reporte_id={self.reporte_id} "
            f"tipo={self.tipo_contacto}>"
        )
