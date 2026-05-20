from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import tipo_rol as crud_tipo
from app.schemas.tipo_rol import TipoRolCreate, TipoRolRead, TipoRolUpdate

router = APIRouter(prefix="/tipos-rol", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=TipoRolRead, status_code=status.HTTP_201_CREATED)
def create_tipo_rol(data: TipoRolCreate, db: Session = Depends(get_db)) -> TipoRolRead:
    return crud_tipo.create(db, data)


@router.get("/{id_tipo}", response_model=TipoRolRead)
def get_tipo_rol(id_tipo: int, db: Session = Depends(get_db)) -> TipoRolRead:
    item = crud_tipo.get(db, id_tipo)
    if not item:
        raise HTTPException(status_code=404, detail="Tipo de rol no encontrado")
    return item


@router.get("/", response_model=list[TipoRolRead])
def list_tipo_rol(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[TipoRolRead]:
    return crud_tipo.list_all(db, skip=skip, limit=limit)


@router.put("/{id_tipo}", response_model=TipoRolRead)
def update_tipo_rol(id_tipo: int, data: TipoRolUpdate, db: Session = Depends(get_db)) -> TipoRolRead:
    item = crud_tipo.get(db, id_tipo)
    if not item:
        raise HTTPException(status_code=404, detail="Tipo de rol no encontrado")
    return crud_tipo.update(db, item, data)


@router.delete("/{id_tipo}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tipo_rol(id_tipo: int, db: Session = Depends(get_db)) -> None:
    item = crud_tipo.get(db, id_tipo)
    if not item:
        raise HTTPException(status_code=404, detail="Tipo de rol no encontrado")
    crud_tipo.delete(db, item)
