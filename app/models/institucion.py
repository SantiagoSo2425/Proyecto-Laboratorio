from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Institucion(Base):
    __tablename__ = "institucion"

    id_institucion: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(unique=True)
