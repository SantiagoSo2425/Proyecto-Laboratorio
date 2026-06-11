from sqlalchemy import ForeignKey, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class ProyectoInstitucion(Base):
    __tablename__ = "proyecto_institucion"
    __table_args__ = (UniqueConstraint("id_proyecto", "id_institucion", name="proyecto_institucion_unique"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    id_proyecto: Mapped[str] = mapped_column(ForeignKey("proyecto.id_proyecto"))
    id_institucion: Mapped[int] = mapped_column(ForeignKey("institucion.id_institucion"))
