from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import institucion as crud_item
from app.schemas.institucion import InstitucionCreate, InstitucionRead, InstitucionUpdate

router = APIRouter(prefix="/instituciones", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=InstitucionRead, status_code=status.HTTP_201_CREATED)
def create_item(data: InstitucionCreate, db: Session = Depends(get_db)) -> InstitucionRead:
    try:
        return crud_item.create(db, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="La institucion ya existe o no se pudo crear") from exc


@router.get("/{id_institucion}", response_model=InstitucionRead)
def get_item(id_institucion: int, db: Session = Depends(get_db)) -> InstitucionRead:
    item = crud_item.get(db, id_institucion)
    if not item:
        raise HTTPException(status_code=404, detail="Institucion no encontrada")
    return item


@router.get("/", response_model=list[InstitucionRead])
def list_items(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[InstitucionRead]:
    return crud_item.list_all(db, skip=skip, limit=limit)


@router.put("/{id_institucion}", response_model=InstitucionRead)
def update_item(id_institucion: int, data: InstitucionUpdate, db: Session = Depends(get_db)) -> InstitucionRead:
    item = crud_item.get(db, id_institucion)
    if not item:
        raise HTTPException(status_code=404, detail="Institucion no encontrada")
    try:
        return crud_item.update(db, item, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="La institucion ya existe o no se pudo actualizar") from exc


@router.delete("/{id_institucion}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(id_institucion: int, db: Session = Depends(get_db)) -> None:
    item = crud_item.get(db, id_institucion)
    if not item:
        raise HTTPException(status_code=404, detail="Institucion no encontrada")
    try:
        crud_item.delete(db, item)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="No se puede eliminar una institucion en uso") from exc
