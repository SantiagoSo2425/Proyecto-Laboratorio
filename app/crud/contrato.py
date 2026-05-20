from sqlalchemy.orm import Session

from app.models.contrato import Contrato
from app.schemas.contrato import ContratoCreate, ContratoUpdate


def get(db: Session, id_value: int) -> Contrato | None:
    return db.get(Contrato, id_value)


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Contrato]:
    return db.query(Contrato).offset(skip).limit(limit).all()


def create(db: Session, data: ContratoCreate) -> Contrato:
    item = Contrato(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def update(db: Session, item: Contrato, data: ContratoUpdate) -> Contrato:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


def delete(db: Session, item: Contrato) -> None:
    db.delete(item)
    db.commit()
