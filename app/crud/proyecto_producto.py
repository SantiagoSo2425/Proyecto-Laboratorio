from sqlalchemy.orm import Session

from app.models.proyecto_producto import ProyectoProducto
from app.schemas.proyecto_producto import ProyectoProductoCreate, ProyectoProductoUpdate


def get(db: Session, id_value: int) -> ProyectoProducto | None:
    return db.get(ProyectoProducto, id_value)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[ProyectoProducto]:
    return db.query(ProyectoProducto).offset(skip).limit(limit).all()


def create(db: Session, data: ProyectoProductoCreate) -> ProyectoProducto:
    item = ProyectoProducto(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: ProyectoProducto, data: ProyectoProductoUpdate) -> ProyectoProducto:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: ProyectoProducto) -> None:
    db.delete(item)
    db.commit()
