from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Producto(Base):
    __tablename__ = "producto"

    id_producto: Mapped[int] = mapped_column(primary_key=True)
    descripcion: Mapped[str]
