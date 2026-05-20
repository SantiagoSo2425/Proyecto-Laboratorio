from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class ProyectoProducto(Base):
    __tablename__ = "proyecto_producto"

    id: Mapped[int] = mapped_column(primary_key=True)
    id_proyecto: Mapped[str] = mapped_column(ForeignKey("proyecto.id_proyecto"))
    id_producto: Mapped[int] = mapped_column(ForeignKey("producto.id_producto"))
