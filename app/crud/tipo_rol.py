from sqlalchemy.orm import Session

from app.models.tipo_rol import TipoRol
from app.schemas.tipo_rol import TipoRolCreate, TipoRolUpdate


def get(db: Session, id_tipo: int) -> TipoRol | None:
    return db.get(TipoRol, id_tipo)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[TipoRol]:
    return db.query(TipoRol).offset(skip).limit(limit).all()


def create(db: Session, data: TipoRolCreate) -> TipoRol:
    tipo_rol = TipoRol(**data.model_dump())
    db.add(tipo_rol)
    db.commit()
    db.refresh(tipo_rol)
    return tipo_rol


def update(db: Session, tipo_rol: TipoRol, data: TipoRolUpdate) -> TipoRol:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(tipo_rol, key, value)
    db.add(tipo_rol)
    db.commit()
    db.refresh(tipo_rol)
    return tipo_rol


def delete(db: Session, tipo_rol: TipoRol) -> None:
    db.delete(tipo_rol)
    db.commit()
