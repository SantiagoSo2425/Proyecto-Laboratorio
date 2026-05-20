from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Rol(Base):
    __tablename__ = "rol"

    id_rol: Mapped[int] = mapped_column(primary_key=True)
    id_tipo: Mapped[int] = mapped_column(ForeignKey("tipo_rol.id_tipo"))
    tipo: Mapped[str] = mapped_column(unique=True)
