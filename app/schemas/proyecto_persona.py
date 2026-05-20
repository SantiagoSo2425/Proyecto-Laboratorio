from datetime import date

from pydantic import BaseModel, ConfigDict


class ProyectoPersonaBase(BaseModel):
    id_proyecto: str
    persona_id: int
    id_rol: int
    horas_semanales: int
    fecha_inicio: date
    fecha_fin: date | None = None


class ProyectoPersonaCreate(ProyectoPersonaBase):
    pass


class ProyectoPersonaUpdate(BaseModel):
    id_proyecto: str | None = None
    persona_id: int | None = None
    id_rol: int | None = None
    horas_semanales: int | None = None
    fecha_inicio: date | None = None
    fecha_fin: date | None = None


class ProyectoPersonaRead(ProyectoPersonaBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
