from pydantic import BaseModel, ConfigDict


class ProyectoBase(BaseModel):
    id_proyecto: str
    nombre: str
    entidad_financiadora: str


class ProyectoCreate(ProyectoBase):
    pass


class ProyectoUpdate(BaseModel):
    nombre: str | None = None
    entidad_financiadora: str | None = None


class ProyectoRead(ProyectoBase):
    model_config = ConfigDict(from_attributes=True)
