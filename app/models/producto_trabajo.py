from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class ProductoTrabajo(Base):
    __tablename__ = "producto_trabajo"

    id: Mapped[int] = mapped_column(primary_key=True)
    id_trabajo: Mapped[int] = mapped_column(ForeignKey("trabajo_grado.id_trabajo"))
    id_producto: Mapped[int] = mapped_column(ForeignKey("producto.id_producto"))
