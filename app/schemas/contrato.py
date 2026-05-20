from pydantic import BaseModel, ConfigDict


class ContratoBase(BaseModel):
    id_proyecto: str
    id_persona: int


class ContratoCreate(ContratoBase):
    pass


class ContratoUpdate(BaseModel):
    id_proyecto: str | None = None
    id_persona: int | None = None


class ContratoRead(ContratoBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
