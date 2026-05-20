from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import contrato as crud_item
from app.schemas.contrato import ContratoCreate, ContratoRead, ContratoUpdate

router = APIRouter(prefix="/contratos", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=ContratoRead, status_code=status.HTTP_201_CREATED)
def create_item(data: ContratoCreate, db: Session = Depends(get_db)) -> ContratoRead:
    return crud_item.create(db, data)


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
    return crud_item.update(db, item, data)


@router.delete("/{id_value}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(id_value: int, db: Session = Depends(get_db)) -> None:
    item = crud_item.get(db, id_value)
    if not item:
        raise HTTPException(status_code=404, detail="Contrato no encontrado")
    crud_item.delete(db, item)
