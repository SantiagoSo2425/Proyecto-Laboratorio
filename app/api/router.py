from fastapi import APIRouter

from app.api.routers import (
    auth,
    contrato,
    institucion,
    persona,
    producto,
    producto_trabajo,
    proyecto,
    proyecto_persona,
    proyecto_producto,
    rol,
    tipo_rol,
    trabajo_grado,
    trabajo_persona,
)

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth.router, tags=["auth"])
api_router.include_router(persona.router, tags=["persona"])
api_router.include_router(institucion.router, tags=["institucion"])
api_router.include_router(tipo_rol.router, tags=["tipo_rol"])
api_router.include_router(rol.router, tags=["rol"])
api_router.include_router(proyecto.router, tags=["proyecto"])
api_router.include_router(trabajo_grado.router, tags=["trabajo_grado"])
api_router.include_router(producto.router, tags=["producto"])
api_router.include_router(proyecto_persona.router, tags=["proyecto_persona"])
api_router.include_router(trabajo_persona.router, tags=["trabajo_persona"])
api_router.include_router(proyecto_producto.router, tags=["proyecto_producto"])
api_router.include_router(producto_trabajo.router, tags=["producto_trabajo"])
api_router.include_router(contrato.router, tags=["contrato"])
