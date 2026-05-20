from sqlalchemy.orm import Session

from app.models.trabajo_grado import TrabajoGrado
from app.schemas.trabajo_grado import TrabajoGradoCreate, TrabajoGradoUpdate


def get(db: Session, id_trabajo: int) -> TrabajoGrado | None:
    return db.get(TrabajoGrado, id_trabajo)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[TrabajoGrado]:
    return db.query(TrabajoGrado).offset(skip).limit(limit).all()


def create(db: Session, data: TrabajoGradoCreate) -> TrabajoGrado:
    trabajo = TrabajoGrado(**data.model_dump())
    db.add(trabajo)
    db.commit()
    db.refresh(trabajo)
    return trabajo


def update(db: Session, trabajo: TrabajoGrado, data: TrabajoGradoUpdate) -> TrabajoGrado:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(trabajo, key, value)
    db.add(trabajo)
    db.commit()
    db.refresh(trabajo)
    return trabajo


def delete(db: Session, trabajo: TrabajoGrado) -> None:
    db.delete(trabajo)
    db.commit()
