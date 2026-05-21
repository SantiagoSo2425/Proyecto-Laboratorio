from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import trabajo_grado as crud_trabajo
from app.schemas.trabajo_grado import TrabajoGradoCreate, TrabajoGradoRead, TrabajoGradoUpdate

router = APIRouter(prefix="/trabajos-grado", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=TrabajoGradoRead, status_code=status.HTTP_201_CREATED)
def create_trabajo(data: TrabajoGradoCreate, db: Session = Depends(get_db)) -> TrabajoGradoRead:
    try:
        return crud_trabajo.create(db, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="Proyecto no existe") from exc


@router.get("/{id_trabajo}", response_model=TrabajoGradoRead)
def get_trabajo(id_trabajo: int, db: Session = Depends(get_db)) -> TrabajoGradoRead:
    item = crud_trabajo.get(db, id_trabajo)
    if not item:
        raise HTTPException(status_code=404, detail="Trabajo de grado no encontrado")
    return item


@router.get("/", response_model=list[TrabajoGradoRead])
def list_trabajos(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[TrabajoGradoRead]:
    return crud_trabajo.list_all(db, skip=skip, limit=limit)


@router.put("/{id_trabajo}", response_model=TrabajoGradoRead)
def update_trabajo(
    id_trabajo: int, data: TrabajoGradoUpdate, db: Session = Depends(get_db)
) -> TrabajoGradoRead:
    item = crud_trabajo.get(db, id_trabajo)
    if not item:
        raise HTTPException(status_code=404, detail="Trabajo de grado no encontrado")
    try:
        return crud_trabajo.update(db, item, data)
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(status_code=400, detail="Proyecto no existe") from exc


@router.delete("/{id_trabajo}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trabajo(id_trabajo: int, db: Session = Depends(get_db)) -> None:
    item = crud_trabajo.get(db, id_trabajo)
    if not item:
        raise HTTPException(status_code=404, detail="Trabajo de grado no encontrado")
    crud_trabajo.delete(db, item)
