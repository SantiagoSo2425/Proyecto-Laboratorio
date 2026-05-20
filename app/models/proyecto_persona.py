from datetime import date

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class ProyectoPersona(Base):
    __tablename__ = "proyecto_persona"

    id: Mapped[int] = mapped_column(primary_key=True)
    id_proyecto: Mapped[str] = mapped_column(ForeignKey("proyecto.id_proyecto"))
    persona_id: Mapped[int] = mapped_column(ForeignKey("persona.id_persona"))
    id_rol: Mapped[int] = mapped_column(ForeignKey("rol.id_rol"))
    horas_semanales: Mapped[int]
    fecha_inicio: Mapped[date]
    fecha_fin: Mapped[date | None]
