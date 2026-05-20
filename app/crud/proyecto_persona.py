from sqlalchemy.orm import Session

from app.models.proyecto_persona import ProyectoPersona
from app.schemas.proyecto_persona import ProyectoPersonaCreate, ProyectoPersonaUpdate


def get(db: Session, id_value: int) -> ProyectoPersona | None:
    return db.get(ProyectoPersona, id_value)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[ProyectoPersona]:
    return db.query(ProyectoPersona).offset(skip).limit(limit).all()


def create(db: Session, data: ProyectoPersonaCreate) -> ProyectoPersona:
    item = ProyectoPersona(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: ProyectoPersona, data: ProyectoPersonaUpdate) -> ProyectoPersona:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: ProyectoPersona) -> None:
    db.delete(item)
    db.commit()
