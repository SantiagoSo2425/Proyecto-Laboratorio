from app.models.base import Base
from app.models.contrato import Contrato
from app.models.institucion import Institucion
from app.models.persona import Persona
from app.models.persona_institucion import PersonaInstitucion
from app.models.producto import Producto
from app.models.producto_trabajo import ProductoTrabajo
from app.models.proyecto import Proyecto
from app.models.proyecto_institucion import ProyectoInstitucion
from app.models.proyecto_persona import ProyectoPersona
from app.models.proyecto_producto import ProyectoProducto
from app.models.rol import Rol
from app.models.tipo_rol import TipoRol
from app.models.trabajo_grado import TrabajoGrado
from app.models.trabajo_persona import TrabajoPersona

__all__ = [
    "Base",
    "Contrato",
    "Institucion",
    "Persona",
    "PersonaInstitucion",
    "Producto",
    "ProductoTrabajo",
    "Proyecto",
    "ProyectoInstitucion",
    "ProyectoPersona",
    "ProyectoProducto",
    "Rol",
    "TipoRol",
    "TrabajoGrado",
    "TrabajoPersona",
]
