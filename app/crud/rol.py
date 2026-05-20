from sqlalchemy.orm import Session

from app.models.rol import Rol
from app.schemas.rol import RolCreate, RolUpdate


def get(db: Session, id_rol: int) -> Rol | None:
    return db.get(Rol, id_rol)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Rol]:
    return db.query(Rol).offset(skip).limit(limit).all()


def create(db: Session, data: RolCreate) -> Rol:
    rol = Rol(**data.model_dump())
    db.add(rol)
    db.commit()
    db.refresh(rol)
    return rol


def update(db: Session, rol: Rol, data: RolUpdate) -> Rol:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(rol, key, value)
    db.add(rol)
    db.commit()
    db.refresh(rol)
    return rol


def delete(db: Session, rol: Rol) -> None:
    db.delete(rol)
    db.commit()
