from pydantic import BaseModel, ConfigDict, EmailStr, Field


class PersonaBase(BaseModel):
    nombre: str
    programa: str
    documento: str
    correo: EmailStr
    institucion: str
    nivel_academico: str
    semestre: int | None = None
    activo: bool = True
    usuario: str


class PersonaCreate(PersonaBase):
    clave: str = Field(min_length=6)


class PersonaUpdate(BaseModel):
    nombre: str | None = None
    programa: str | None = None
    documento: str | None = None
    correo: EmailStr | None = None
    institucion: str | None = None
    nivel_academico: str | None = None
    semestre: int | None = None
    activo: bool | None = None
    usuario: str | None = None
    clave: str | None = None


class PersonaRead(PersonaBase):
    model_config = ConfigDict(from_attributes=True)

    id_persona: int
