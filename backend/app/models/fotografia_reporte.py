# ============================================================
# Pet Rescue - Modelo SQLAlchemy: FotografiaReporte
# ============================================================

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.orm import relationship

from app.database.connection import Base


class FotografiaReporte(Base):
    __tablename__ = "fotografias_reporte"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    reporte_id = Column(
        Integer,
        ForeignKey(
            "reportes.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    nombre_archivo = Column(
        String(255),
        nullable=False,
    )

    ruta_archivo = Column(
        String(500),
        nullable=False,
    )

    tipo_mime = Column(
        String(100),
        nullable=False,
    )

    tamano_bytes = Column(
        Integer,
        nullable=False,
    )

    fecha_creacion = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
    )

    reporte = relationship(
        "Reporte",
        backref="fotografias",
    )

    def __repr__(self):
        return (
            f"<FotografiaReporte id={self.id} "
            f"reporte_id={self.reporte_id} "
            f"nombre_archivo={self.nombre_archivo}>"
        )
