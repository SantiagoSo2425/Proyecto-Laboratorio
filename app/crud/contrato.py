from sqlalchemy.orm import Session

from app.models.contrato import Contrato
from app.models.persona import Persona
from app.models.proyecto import Proyecto
from app.schemas.contrato import ContratoCreate, ContratoUpdate


def get(db: Session, id_value: int) -> Contrato | None:
    item = db.get(Contrato, id_value)
    if item:
        _attach_labels(db, [item])
    return item


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Contrato]:
    items = db.query(Contrato).offset(skip).limit(limit).all()
    _attach_labels(db, items)
    return items


def create(db: Session, data: ContratoCreate) -> Contrato:
    item = Contrato(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    _attach_labels(db, [item])
    return item


def update(db: Session, item: Contrato, data: ContratoUpdate) -> Contrato:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.add(item)
    db.commit()
    db.refresh(item)
    _attach_labels(db, [item])
    return item


def delete(db: Session, item: Contrato) -> None:
    db.delete(item)
    db.commit()


def _attach_labels(db: Session, items: list[Contrato]) -> None:
    if not items:
        return

    project_ids = {item.id_proyecto for item in items}
    person_ids = {item.id_persona for item in items}
    projects = {item.id_proyecto: item for item in db.query(Proyecto).filter(Proyecto.id_proyecto.in_(project_ids)).all()}
    personas = {item.id_persona: item for item in db.query(Persona).filter(Persona.id_persona.in_(person_ids)).all()}

    for item in items:
        setattr(item, "proyecto_nombre", projects.get(item.id_proyecto).nombre if projects.get(item.id_proyecto) else None)
        setattr(item, "persona_nombre", personas.get(item.id_persona).nombre if personas.get(item.id_persona) else None)
