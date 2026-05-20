from pydantic import BaseModel, ConfigDict


class TipoRolBase(BaseModel):
    nombre: str


class TipoRolCreate(TipoRolBase):
    pass


class TipoRolUpdate(BaseModel):
    nombre: str | None = None


class TipoRolRead(TipoRolBase):
    model_config = ConfigDict(from_attributes=True)

    id_tipo: int
