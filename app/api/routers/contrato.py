from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import contrato as crud_item
from app.schemas.contrato import ContratoCreate, ContratoRead, ContratoUpdate

router = APIRouter(prefix="/contratos", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=ContratoRead, status_code=status.HTTP_201_CREATED)
def create_item(data: ContratoCreate, db: Session = Depends(get_db)) -> ContratoRead:
    try:
        return crud_item.create(db, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="No se pudo crear el contrato") from exc


@router.get("/{id_value}", response_model=ContratoRead)
def get_item(id_value: int, db: Session = Depends(get_db)) -> ContratoRead:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Contrato no encontrado")
    return item


@router.get("/", response_model=list[ContratoRead])
def list_items(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[ContratoRead]:
    return crud_item.list_all(db, skip=skip, limit=limit)


@router.put("/{id_value}", response_model=ContratoRead)
def update_item(
    id_value: int, data: ContratoUpdate, db: Session = Depends(get_db)
) -> ContratoRead:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Contrato no encontrado")
    try:
        return crud_item.update(db, item, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="No se pudo actualizar el contrato") from exc


@router.delete("/{id_value}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(id_value: int, db: Session = Depends(get_db)) -> None:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Contrato no encontrado")
    try:
        crud_item.delete(db, item)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="No se pudo eliminar el contrato") from exc
