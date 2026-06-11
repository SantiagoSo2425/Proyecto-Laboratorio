from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.institucion import InstitucionRead


class ProyectoBase(BaseModel):
    id_proyecto: str
    codigo_proyecto: str | None = None
    nombre: str
    entidad_financiadora: str
    tipo: Literal["investigacion", "extension"] = "investigacion"


class ProyectoCreate(ProyectoBase):
    institucion_ids: list[int] = Field(default_factory=list)


class ProyectoUpdate(BaseModel):
    codigo_proyecto: str | None = None
    nombre: str | None = None
    entidad_financiadora: str | None = None
    tipo: Literal["investigacion", "extension"] | None = None
    institucion_ids: list[int] | None = None


class ProyectoRead(ProyectoBase):
    model_config = ConfigDict(from_attributes=True)

    instituciones: list[InstitucionRead] = Field(default_factory=list)
