# ============================================================
# Pet Rescue - Modelo SQLAlchemy: Mascota
# ============================================================
from sqlalchemy import Column, Integer, String, Text
from app.database.connection import Base


class Mascota(Base):
    __tablename__ = "mascotas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100))
    especie = Column(String(50), nullable=False)
    raza = Column(String(100))
    color = Column(String(50), nullable=False)
    tamano = Column(String(20), nullable=False)
    edad_aproximada = Column(Integer)
    senas_particulares = Column(Text)

    def __repr__(self):
        return f"<Mascota id={self.id} nombre={self.nombre} especie={self.especie}>"
