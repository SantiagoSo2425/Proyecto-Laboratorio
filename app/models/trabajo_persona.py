from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class TrabajoPersona(Base):
    __tablename__ = "trabajo_persona"

    id: Mapped[int] = mapped_column(primary_key=True)
    id_trabajo: Mapped[int] = mapped_column(ForeignKey("trabajo_grado.id_trabajo"))
    id_persona: Mapped[int] = mapped_column(ForeignKey("persona.id_persona"))
    id_rol: Mapped[int] = mapped_column(ForeignKey("rol.id_rol"))
