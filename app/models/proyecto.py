from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Proyecto(Base):
    __tablename__ = "proyecto"

    id_proyecto: Mapped[str] = mapped_column(primary_key=True)
    codigo_proyecto: Mapped[str] = mapped_column(unique=True)
    nombre: Mapped[str]
    entidad_financiadora: Mapped[str]
    tipo: Mapped[str] = mapped_column(default="investigacion")
