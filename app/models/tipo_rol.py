from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class TipoRol(Base):
    __tablename__ = "tipo_rol"

    id_tipo: Mapped[int] = mapped_column(primary_key=True)
    nombre: Mapped[str] = mapped_column(unique=True)
