from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class TrabajoGrado(Base):
    __tablename__ = "trabajo_grado"

    id_trabajo: Mapped[int] = mapped_column(primary_key=True)
    id_proyecto: Mapped[str] = mapped_column(ForeignKey("proyecto.id_proyecto"))
    nombre: Mapped[str]
    facultad: Mapped[str]
