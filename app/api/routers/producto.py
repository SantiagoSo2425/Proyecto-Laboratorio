from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.crud import producto as crud_producto
from app.schemas.producto import ProductoCreate, ProductoRead, ProductoUpdate

router = APIRouter(prefix="/productos", dependencies=[Depends(get_current_user)])


@router.post("/", response_model=ProductoRead, status_code=status.HTTP_201_CREATED)
def create_producto(data: ProductoCreate, db: Session = Depends(get_db)) -> ProductoRead:
    return crud_producto.create(db, data)


@router.get("/{id_producto}", response_model=ProductoRead)
def get_producto(id_producto: int, db: Session = Depends(get_db)) -> ProductoRead:
    item = crud_producto.get(db, id_producto)
    if not item:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return item


@router.get("/", response_model=list[ProductoRead])
def list_productos(db: Session = Depends(get_db), skip: int = 0, limit: int = 100) -> list[ProductoRead]:
    return crud_producto.list_all(db, skip=skip, limit=limit)


@router.put("/{id_producto}", response_model=ProductoRead)
def update_producto(
    id_producto: int, data: ProductoUpdate, db: Session = Depends(get_db)
) -> ProductoRead:
    item = crud_producto.get(db, id_producto)
    if not item:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return crud_producto.update(db, item, data)


@router.delete("/{id_producto}", status_code=status.HTTP_204_NO_CONTENT)
def delete_producto(id_producto: int, db: Session = Depends(get_db)) -> None:
    item = crud_producto.get(db, id_producto)
    if not item:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    crud_producto.delete(db, item)
