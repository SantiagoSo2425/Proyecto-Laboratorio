from pydantic import BaseModel, ConfigDict


class TrabajoGradoBase(BaseModel):
    id_proyecto: str
    nombre: str
    facultad: str


class TrabajoGradoCreate(TrabajoGradoBase):
    pass


class TrabajoGradoUpdate(BaseModel):
    id_proyecto: str | None = None
    nombre: str | None = None
    facultad: str | None = None


class TrabajoGradoRead(TrabajoGradoBase):
    model_config = ConfigDict(from_attributes=True)

    id_trabajo: int
