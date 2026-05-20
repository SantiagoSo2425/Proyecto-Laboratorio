from pydantic import BaseModel, ConfigDict


class TrabajoPersonaBase(BaseModel):
    id_trabajo: int
    id_persona: int
    id_rol: int


class TrabajoPersonaCreate(TrabajoPersonaBase):
    pass


class TrabajoPersonaUpdate(BaseModel):
    id_trabajo: int | None = None
    id_persona: int | None = None
    id_rol: int | None = None


class TrabajoPersonaRead(TrabajoPersonaBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
