from sqlalchemy.orm import Session

from app.models.trabajo_persona import TrabajoPersona
from app.schemas.trabajo_persona import TrabajoPersonaCreate, TrabajoPersonaUpdate


def get(db: Session, id_value: int) -> TrabajoPersona | None:
    return db.get(TrabajoPersona, id_value)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[TrabajoPersona]:
    return db.query(TrabajoPersona).offset(skip).limit(limit).all()


def create(db: Session, data: TrabajoPersonaCreate) -> TrabajoPersona:
    item = TrabajoPersona(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: TrabajoPersona, data: TrabajoPersonaUpdate) -> TrabajoPersona:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: TrabajoPersona) -> None:
    db.delete(item)
    db.commit()
