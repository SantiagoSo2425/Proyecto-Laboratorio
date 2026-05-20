from pydantic import BaseModel, ConfigDict


class ProductoTrabajoBase(BaseModel):
    id_trabajo: int
    id_producto: int


class ProductoTrabajoCreate(ProductoTrabajoBase):
    pass


class ProductoTrabajoUpdate(BaseModel):
    id_trabajo: int | None = None
    id_producto: int | None = None


class ProductoTrabajoRead(ProductoTrabajoBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
