from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import proyecto as crud_proyecto
from app.schemas.proyecto import ProyectoCreate, ProyectoRead, ProyectoUpdate

router = APIRouter(prefix="/proyectos", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=ProyectoRead, status_code=status.HTTP_201_CREATED)
def create_proyecto(data: ProyectoCreate, db: Session = Depends(get_db)) -> ProyectoRead:
    return crud_proyecto.create(db, data)


@router.get("/{id_proyecto}", response_model=ProyectoRead)
def get_proyecto(id_proyecto: str, db: Session = Depends(get_db)) -> ProyectoRead:
    item = crud_proyecto.get(db, id_proyecto)
    if not item:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    return item


@router.get("/", response_model=list[ProyectoRead])
def list_proyectos(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[ProyectoRead]:
    return crud_proyecto.list_all(db, skip=skip, limit=limit)


@router.put("/{id_proyecto}", response_model=ProyectoRead)
def update_proyecto(
    id_proyecto: str, data: ProyectoUpdate, db: Session = Depends(get_db)
) -> ProyectoRead:
    item = crud_proyecto.get(db, id_proyecto)
    if not item:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    return crud_proyecto.update(db, item, data)


@router.delete("/{id_proyecto}", status_code=status.HTTP_204_NO_CONTENT)
def delete_proyecto(id_proyecto: str, db: Session = Depends(get_db)) -> None:
    item = crud_proyecto.get(db, id_proyecto)
    if not item:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    crud_proyecto.delete(db, item)
