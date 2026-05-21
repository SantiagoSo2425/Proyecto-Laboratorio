from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import persona as crud_persona
from app.schemas.persona import PersonaCreate, PersonaPasswordChange, PersonaRead, PersonaUpdate
from app.security.password import hash_password, verify_password

router = APIRouter(prefix="/personas")


@router.post("/", response_model=PersonaRead, status_code=status.HTTP_201_CREATED)
def create_persona(data: PersonaCreate, db: Session = Depends(get_db)) -> PersonaRead:
    return crud_persona.create(db, data)


@router.get("/{id_persona}", response_model=PersonaRead)
def get_persona(
    id_persona: int,
    db: Session = Depends(get_db),
    _user=Depends(get_current_user),
) -> PersonaRead:
    persona = crud_persona.get(db, id_persona)
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    return persona


@router.get("/", response_model=list[PersonaRead])
def list_personas(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    _user=Depends(get_current_user),
) -> list[PersonaRead]:
    return crud_persona.list_all(db, skip=skip, limit=limit)


@router.put("/{id_persona}", response_model=PersonaRead)
def update_persona(
    id_persona: int,
    data: PersonaUpdate,
    db: Session = Depends(get_db),
    _user=Depends(get_current_user),
) -> PersonaRead:
    persona = crud_persona.get(db, id_persona)
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    return crud_persona.update(db, persona, data)


@router.delete("/{id_persona}", status_code=status.HTTP_204_NO_CONTENT)
def delete_persona(
    id_persona: int,
    db: Session = Depends(get_db),
    _user=Depends(get_current_user),
) -> None:
    persona = crud_persona.get(db, id_persona)
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    crud_persona.delete(db, persona)


@router.post("/{id_persona}/password", status_code=status.HTTP_204_NO_CONTENT)
def change_password(
    id_persona: int,
    data: PersonaPasswordChange,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
) -> None:
    if user.id_persona != id_persona:
        raise HTTPException(status_code=403, detail="No autorizado")

    persona = crud_persona.get(db, id_persona)
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")

    if not verify_password(data.current_password, persona.clave_hash):
        raise HTTPException(status_code=400, detail="Clave actual incorrecta")

    persona.clave_hash = hash_password(data.new_password)
    db.add(persona)
    db.commit()
