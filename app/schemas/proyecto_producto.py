from pydantic import BaseModel, ConfigDict


class ProyectoProductoBase(BaseModel):
    id_proyecto: str
    id_producto: int


class ProyectoProductoCreate(ProyectoProductoBase):
    pass


class ProyectoProductoUpdate(BaseModel):
    id_proyecto: str | None = None
    id_producto: int | None = None


class ProyectoProductoRead(ProyectoProductoBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
