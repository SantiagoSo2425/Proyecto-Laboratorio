from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Persona(Base):
    __tablename__ = "persona"

    id_persona: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str]
    programa: Mapped[str]
    documento: Mapped[str] = mapped_column(unique=True)
    correo: Mapped[str] = mapped_column(unique=True)
    institucion: Mapped[str]
    nivel_academico: Mapped[str]
    semestre: Mapped[int | None]
    activo: Mapped[bool] = mapped_column(default=True)
    usuario: Mapped[str] = mapped_column(unique=True)
    clave_hash: Mapped[str]
