from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import trabajo_persona as crud_item
from app.schemas.trabajo_persona import TrabajoPersonaCreate, TrabajoPersonaRead, TrabajoPersonaUpdate

router = APIRouter(prefix="/trabajo-personas", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=TrabajoPersonaRead, status_code=status.HTTP_201_CREATED)
def create_item(data: TrabajoPersonaCreate, db: Session = Depends(get_db)) -> TrabajoPersonaRead:
    return crud_item.create(db, data)


@router.get("/{id_value}", response_model=TrabajoPersonaRead)
def get_item(id_value: int, db: Session = Depends(get_db)) -> TrabajoPersonaRead:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Relacion no encontrada")
    return item


@router.get("/", response_model=list[TrabajoPersonaRead])
def list_items(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[TrabajoPersonaRead]:
    return crud_item.list_all(db, skip=skip, limit=limit)


@router.put("/{id_value}", response_model=TrabajoPersonaRead)
def update_item(
    id_value: int, data: TrabajoPersonaUpdate, db: Session = Depends(get_db)
) -> TrabajoPersonaRead:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Relacion no encontrada")
    return crud_item.update(db, item, data)


@router.delete("/{id_value}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(id_value: int, db: Session = Depends(get_db)) -> None:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Relacion no encontrada")
    crud_item.delete(db, item)
