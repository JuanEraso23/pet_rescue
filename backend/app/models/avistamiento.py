# ============================================================
# Pet Rescue - Modelo SQLAlchemy: Avistamiento
# ============================================================
from sqlalchemy import Column, Integer, String, Date, Time, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.connection import Base


class Avistamiento(Base):
    __tablename__ = "avistamientos"

    id = Column(Integer, primary_key=True, index=True)
    reporte_id = Column(
        Integer,
        ForeignKey("reportes.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    descripcion = Column(String(500), nullable=False)
    ubicacion_aproximada = Column(String(200), nullable=False)
    fecha_avistamiento = Column(Date, nullable=False)
    hora_avistamiento = Column(Time, nullable=True)
    fecha_creacion = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )

    # Relación con Reporte
    reporte = relationship(
        "Reporte",
        back_populates="avistamientos",
    )

    def __repr__(self):
        return (
            f"<Avistamiento id={self.id} "
            f"reporte_id={self.reporte_id}>"
        )