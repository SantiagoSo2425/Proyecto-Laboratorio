from sqlalchemy.orm import Session

from app.models.proyecto import Proyecto
from app.schemas.proyecto import ProyectoCreate, ProyectoUpdate


def get(db: Session, id_proyecto: str) -> Proyecto | None:
    return db.get(Proyecto, id_proyecto)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Proyecto]:
    return db.query(Proyecto).offset(skip).limit(limit).all()


def create(db: Session, data: ProyectoCreate) -> Proyecto:
    proyecto = Proyecto(**data.model_dump())
    db.add(proyecto)
    db.commit()
    db.refresh(proyecto)
    return proyecto


def update(db: Session, proyecto: Proyecto, data: ProyectoUpdate) -> Proyecto:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(proyecto, key, value)
    db.add(proyecto)
    db.commit()
    db.refresh(proyecto)
    return proyecto


def delete(db: Session, proyecto: Proyecto) -> None:
    db.delete(proyecto)
    db.commit()
