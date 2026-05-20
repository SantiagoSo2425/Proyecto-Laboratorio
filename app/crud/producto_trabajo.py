from sqlalchemy.orm import Session

from app.models.producto_trabajo import ProductoTrabajo
from app.schemas.producto_trabajo import ProductoTrabajoCreate, ProductoTrabajoUpdate


def get(db: Session, id_value: int) -> ProductoTrabajo | None:
    return db.get(ProductoTrabajo, id_value)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[ProductoTrabajo]:
    return db.query(ProductoTrabajo).offset(skip).limit(limit).all()


def create(db: Session, data: ProductoTrabajoCreate) -> ProductoTrabajo:
    item = ProductoTrabajo(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: ProductoTrabajo, data: ProductoTrabajoUpdate) -> ProductoTrabajo:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: ProductoTrabajo) -> None:
    db.delete(item)
    db.commit()
