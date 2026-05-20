from sqlalchemy.orm import Session

from app.models.persona import Persona
from app.schemas.persona import PersonaCreate, PersonaUpdate
from app.security.password import hash_password


def get(db: Session, id_persona: int) -> Persona | None:
    return db.get(Persona, id_persona)


def get_by_usuario(db: Session, usuario: str) -> Persona | None:
    return db.query(Persona).filter(Persona.usuario == usuario).first()


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Persona]:
    return db.query(Persona).offset(skip).limit(limit).all()


def create(db: Session, data: PersonaCreate) -> Persona:
    persona = Persona(
        nombre=data.nombre,
        programa=data.programa,
        documento=data.documento,
        correo=data.correo,
        institucion=data.institucion,
        nivel_academico=data.nivel_academico,
        semestre=data.semestre,
        activo=data.activo,
        usuario=data.usuario,
        clave_hash=hash_password(data.clave),
    )
    db.add(persona)
    db.commit()
    db.refresh(persona)
    return persona


def update(db: Session, persona: Persona, data: PersonaUpdate) -> Persona:
    values = data.model_dump(exclude_unset=True)
    clave = values.pop("clave", None)
    for key, value in values.items():
        setattr(persona, key, value)
    if clave:
        persona.clave_hash = hash_password(clave)
    db.add(persona)
    db.commit()
    db.refresh(persona)
    return persona


def delete(db: Session, persona: Persona) -> None:
    db.delete(persona)
    db.commit()
