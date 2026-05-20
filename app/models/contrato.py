from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Contrato(Base):
    __tablename__ = "contrato"

    id: Mapped[int] = mapped_column(primary_key=True)
    id_proyecto: Mapped[str] = mapped_column(ForeignKey("proyecto.id_proyecto"))
    id_persona: Mapped[int] = mapped_column(ForeignKey("persona.id_persona"))
