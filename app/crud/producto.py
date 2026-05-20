from sqlalchemy.orm import Session

from app.models.producto import Producto
from app.schemas.producto import ProductoCreate, ProductoUpdate


def get(db: Session, id_producto: int) -> Producto | None:
    return db.get(Producto, id_producto)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Producto]:
    return db.query(Producto).offset(skip).limit(limit).all()


def create(db: Session, data: ProductoCreate) -> Producto:
    producto = Producto(**data.model_dump())
    db.add(producto)
    db.commit()
    db.refresh(producto)
    return producto


def update(db: Session, producto: Producto, data: ProductoUpdate) -> Producto:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(producto, key, value)
    db.add(producto)
    db.commit()
    db.refresh(producto)
    return producto


def delete(db: Session, producto: Producto) -> None:
    db.delete(producto)
    db.commit()
