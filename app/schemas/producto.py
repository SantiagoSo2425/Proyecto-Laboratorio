from pydantic import BaseModel, ConfigDict


class ProductoBase(BaseModel):
    descripcion: str


class ProductoCreate(ProductoBase):
    pass


class ProductoUpdate(BaseModel):
    descripcion: str | None = None


class ProductoRead(ProductoBase):
    model_config = ConfigDict(from_attributes=True)

    id_producto: int
