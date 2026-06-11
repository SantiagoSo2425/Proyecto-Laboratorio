from sqlalchemy.orm import Session

from app.models.institucion import Institucion
from app.schemas.institucion import InstitucionCreate, InstitucionUpdate


def get(db: Session, id_institucion: int) -> Institucion | None:
    return db.get(Institucion, id_institucion)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Institucion]:
    return db.query(Institucion).order_by(Institucion.nombre).offset(skip).limit(limit).all()


def create(db: Session, data: InstitucionCreate) -> Institucion:
    item = Institucion(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: Institucion, data: InstitucionUpdate) -> Institucion:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: Institucion) -> None:
    db.delete(item)
    db.commit()
