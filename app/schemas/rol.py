from pydantic import BaseModel, ConfigDict


class RolBase(BaseModel):
    id_tipo: int
    tipo: str


class RolCreate(RolBase):
    pass


class RolUpdate(BaseModel):
    id_tipo: int | None = None
    tipo: str | None = None


class RolRead(RolBase):
    model_config = ConfigDict(from_attributes=True)

    id_rol: int
