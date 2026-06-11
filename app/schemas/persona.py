from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.schemas.institucion import InstitucionRead


class PersonaBase(BaseModel):
    nombre: str
    programa: str
    documento: str
    correo: EmailStr
    nivel_academico: str
    semestre: int | None = None
    activo: bool = True
    usuario: str


class PersonaCreate(PersonaBase):
    clave: str = Field(min_length=6)
    institucion_ids: list[int] = Field(default_factory=list)


class PersonaUpdate(BaseModel):
    nombre: str | None = None
    programa: str | None = None
    documento: str | None = None
    correo: EmailStr | None = None
    nivel_academico: str | None = None
    semestre: int | None = None
    activo: bool | None = None
    usuario: str | None = None
    clave: str | None = None
    institucion_ids: list[int] | None = None


class PersonaPasswordChange(BaseModel):
    current_password: str = Field(min_length=6)
    new_password: str = Field(min_length=6)


class PersonaRead(PersonaBase):
    model_config = ConfigDict(from_attributes=True)

    id_persona: int
    instituciones: list[InstitucionRead] = Field(default_factory=list)
