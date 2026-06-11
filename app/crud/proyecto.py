from sqlalchemy.orm import Session

from app.models.institucion import Institucion
from app.models.proyecto_institucion import ProyectoInstitucion
from app.models.proyecto import Proyecto
from app.schemas.proyecto import ProyectoCreate, ProyectoUpdate


def get(db: Session, id_proyecto: str) -> Proyecto | None:
    proyecto = db.get(Proyecto, id_proyecto)
    if proyecto:
        _attach_instituciones(db, [proyecto])
    return proyecto


def list_all(db: Session, skip: int = 0, limit: int = 100) -> list[Proyecto]:
    proyectos = db.query(Proyecto).offset(skip).limit(limit).all()
    _attach_instituciones(db, proyectos)
    return proyectos


def create(db: Session, data: ProyectoCreate) -> Proyecto:
    proyecto = Proyecto(
        id_proyecto=data.id_proyecto,
        codigo_proyecto=_normalize_codigo(data.codigo_proyecto, data.id_proyecto),
        nombre=data.nombre,
        entidad_financiadora=data.entidad_financiadora,
        tipo=data.tipo,
    )
    db.add(proyecto)
    db.flush()
    _sync_instituciones(db, proyecto.id_proyecto, data.institucion_ids)
    db.commit()
    db.refresh(proyecto)
    _attach_instituciones(db, [proyecto])
    return proyecto


def update(db: Session, proyecto: Proyecto, data: ProyectoUpdate) -> Proyecto:
    values = data.model_dump(exclude_unset=True)
    institucion_ids = values.pop("institucion_ids", None)
    if "codigo_proyecto" in values:
        values["codigo_proyecto"] = _normalize_codigo(values["codigo_proyecto"], proyecto.id_proyecto)
    for key, value in values.items():
        setattr(proyecto, key, value)
    db.add(proyecto)
    if institucion_ids is not None:
        _sync_instituciones(db, proyecto.id_proyecto, institucion_ids)
    db.commit()
    db.refresh(proyecto)
    _attach_instituciones(db, [proyecto])
    return proyecto


def delete(db: Session, proyecto: Proyecto) -> None:
    db.delete(proyecto)
    db.commit()


def _sync_instituciones(db: Session, id_proyecto: str, institucion_ids: list[int]) -> None:
    db.query(ProyectoInstitucion).filter(ProyectoInstitucion.id_proyecto == id_proyecto).delete(synchronize_session=False)
    for id_institucion in institucion_ids:
        db.add(ProyectoInstitucion(id_proyecto=id_proyecto, id_institucion=id_institucion))


def _attach_instituciones(db: Session, proyectos: list[Proyecto]) -> None:
    ids = [proyecto.id_proyecto for proyecto in proyectos]
    if not ids:
        return

    rows = (
        db.query(ProyectoInstitucion.id_proyecto, Institucion)
        .join(Institucion, Institucion.id_institucion == ProyectoInstitucion.id_institucion)
        .filter(ProyectoInstitucion.id_proyecto.in_(ids))
        .order_by(Institucion.nombre)
        .all()
    )
    grouped: dict[str, list[Institucion]] = {id_proyecto: [] for id_proyecto in ids}
    for id_proyecto, institucion in rows:
        grouped.setdefault(id_proyecto, []).append(institucion)
    for proyecto in proyectos:
        setattr(proyecto, "instituciones", grouped.get(proyecto.id_proyecto, []))


def _normalize_codigo(codigo: str | None, fallback: str) -> str:
    if codigo is None:
        return fallback
    cleaned = codigo.strip()
    return cleaned or fallback
