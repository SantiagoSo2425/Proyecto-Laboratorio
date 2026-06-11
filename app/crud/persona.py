from sqlalchemy.orm import Session

from app.models.institucion import Institucion
from app.models.persona_institucion import PersonaInstitucion
from app.models.persona import Persona
from app.schemas.persona import PersonaCreate, PersonaUpdate
from app.security.password import hash_password


def get(db: Session, id_persona: int) -> Persona | None:
    persona = db.get(Persona, id_persona)
    if persona:
        _attach_instituciones(db, [persona])
    return persona


def get_by_usuario(db: Session, usuario: str) -> Persona | None:
    persona = db.query(Persona).filter(Persona.usuario == usuario).first()
    if persona:
        _attach_instituciones(db, [persona])
    return persona


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Persona]:
    personas = db.query(Persona).offset(skip).limit(limit).all()
    _attach_instituciones(db, personas)
    return personas


def create(db: Session, data: PersonaCreate) -> Persona:
    persona = Persona(
        nombre=data.nombre,
        programa=data.programa,
        documento=data.documento,
        correo=data.correo,
        nivel_academico=data.nivel_academico,
        semestre=data.semestre,
        activo=data.activo,
        usuario=data.usuario,
        clave_hash=hash_password(data.clave),
    )
    db.add(persona)
    db.flush()
    _sync_instituciones(db, persona.id_persona, data.institucion_ids)
    db.commit()
    db.refresh(persona)
    _attach_instituciones(db, [persona])
    return persona


def update(db: Session, persona: Persona, data: PersonaUpdate) -> Persona:
    values = data.model_dump(exclude_unset=True)
    clave = values.pop("clave", None)
    institucion_ids = values.pop("institucion_ids", None)
    for key, value in values.items():
        setattr(persona, key, value)
    if clave:
        persona.clave_hash = hash_password(clave)
    db.add(persona)
    if institucion_ids is not None:
        _sync_instituciones(db, persona.id_persona, institucion_ids)
    db.commit()
    db.refresh(persona)
    _attach_instituciones(db, [persona])
    return persona


def delete(db: Session, persona: Persona) -> None:
    db.delete(persona)
    db.commit()


def _sync_instituciones(db: Session, id_persona: int, institucion_ids: list[int]) -> None:
    db.query(PersonaInstitucion).filter(PersonaInstitucion.id_persona == id_persona).delete(synchronize_session=False)
    for id_institucion in institucion_ids:
        db.add(PersonaInstitucion(id_persona=id_persona, id_institucion=id_institucion))


def _attach_instituciones(db: Session, personas: list[Persona]) -> None:
    ids = [persona.id_persona for persona in personas]
    if not ids:
        return

    rows = (
        db.query(PersonaInstitucion.id_persona, Institucion)
        .join(Institucion, Institucion.id_institucion == PersonaInstitucion.id_institucion)
        .filter(PersonaInstitucion.id_persona.in_(ids))
        .order_by(Institucion.nombre)
        .all()
    )
    grouped: dict[int, list[Institucion]] = {id_persona: [] for id_persona in ids}
    for id_persona, institucion in rows:
        grouped.setdefault(id_persona, []).append(institucion)
    for persona in personas:
        setattr(persona, "instituciones", grouped.get(persona.id_persona, []))
