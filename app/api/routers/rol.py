from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import rol as crud_rol
from app.schemas.rol import RolCreate, RolRead, RolUpdate

router = APIRouter(prefix="/roles", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=RolRead, status_code=status.HTTP_201_CREATED)
def create_rol(data: RolCreate, db: Session = Depends(get_db)) -> RolRead:
    return crud_rol.create(db, data)


@router.get("/{id_rol}", response_model=RolRead)
def get_rol(id_rol: int, db: Session = Depends(get_db)) -> RolRead:
    item = crud_rol.get(db, id_rol)
    if not item:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    return item


@router.get("/", response_model=list[RolRead])
def list_roles(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[RolRead]:
    return crud_rol.list_all(db, skip=skip, limit=limit)


@router.put("/{id_rol}", response_model=RolRead)
def update_rol(id_rol: int, data: RolUpdate, db: Session = Depends(get_db)) -> RolRead:
    item = crud_rol.get(db, id_rol)
    if not item:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    return crud_rol.update(db, item, data)


@router.delete("/{id_rol}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rol(id_rol: int, db: Session = Depends(get_db)) -> None:
    item = crud_rol.get(db, id_rol)
    if not item:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    crud_rol.delete(db, item)
