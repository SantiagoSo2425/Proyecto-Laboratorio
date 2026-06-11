from pydantic import BaseModel, ConfigDict


class InstitucionBase(BaseModel):
    nombre: str


class InstitucionCreate(InstitucionBase):
    pass


class InstitucionUpdate(BaseModel):
    nombre: str | None = None


class InstitucionRead(InstitucionBase):
    model_config = ConfigDict(from_attributes=True)

    id_institucion: int
