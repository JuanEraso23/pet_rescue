# ============================================================
# Pet Rescue - Modelo SQLAlchemy: Reporte
# ============================================================
from sqlalchemy import Column, Integer, String, Text, Date, Time, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.database.connection import Base


class Reporte(Base):
    __tablename__ = "reportes"

    id = Column(Integer, primary_key=True, index=True)
    codigo = Column(String(20), unique=True, nullable=False, index=True)
    mascota_id = Column(Integer, ForeignKey("mascotas.id", ondelete="CASCADE"), nullable=False, index=True)
    titulo = Column(String(200), nullable=False)
    descripcion = Column(Text, nullable=False)
    tipo = Column(String(20), nullable=False, default="Perdida")
    estado = Column(String(20), nullable=False, default="Activo", index=True)
    ubicacion_extravio = Column(String(200), nullable=False)
    fecha_extravio = Column(Date, nullable=False)
    hora_extravio = Column(Time)
    fecha_creacion = Column(DateTime, nullable=False, server_default=func.now())

    # Relación con Mascota
    mascota = relationship("Mascota", backref="reportes")

    # Relación 1 a 1 con Contacto (HU5)
    contacto = relationship(
        "ContactoReporte",
        back_populates="reporte",
        uselist=False,
        cascade="all, delete-orphan",
    )

    def __repr__(self):
        return f"<Reporte id={self.id} codigo={self.codigo} estado={self.estado}>"