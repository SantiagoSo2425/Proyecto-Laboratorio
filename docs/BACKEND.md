# Documentacion del Backend (FastAPI)

## 1) Vision general
El backend expone una API REST en FastAPI para gestionar proyectos de laboratorio, personas, roles, productos y relaciones academicas/administrativas.

Stack principal:
- FastAPI
- SQLAlchemy 2
- PostgreSQL
- Pydantic v2
- JWT (python-jose)
- Passlib/Bcrypt

Archivo de entrada:
- `main.py`

Router principal:
- `app/api/router.py`

## 2) Arquitectura por capas
El proyecto backend sigue una separacion por responsabilidades:
- `app/api/routers`: endpoints HTTP por modulo.
- `app/crud`: operaciones de datos por entidad.
- `app/models`: modelos ORM SQLAlchemy.
- `app/schemas`: contratos de entrada/salida (DTOs Pydantic).
- `app/security`: utilidades de JWT y hashing.
- `app/db`: engine y sesiones de BD.
- `app/core`: configuracion centralizada por variables de entorno.

## 3) Modulos API implementados
Routers registrados en `app/api/router.py`:
- `auth`
- `persona`
- `institucion`
- `tipo_rol`
- `rol`
- `proyecto`
- `trabajo_grado`
- `producto`
- `proyecto_persona`
- `trabajo_persona`
- `proyecto_producto`
- `producto_trabajo`
- `contrato`
- `proyecto_institucion`
- `persona_institucion`

## 4) Autenticacion JWT
### Flujo
1. Cliente envía credenciales a `POST /api/v1/auth/login`.
2. Backend valida usuario/clave (`crud.persona.get_by_usuario` + `verify_password`).
3. Si son validas, genera `access_token` JWT (`app/security/jwt.py`).
4. Cliente usa `Authorization: Bearer <token>` en endpoints protegidos.
5. Dependencia `get_current_user` valida token y resuelve usuario actual.

### Configuracion relevante
- `SECRET_KEY`
- `ALGORITHM` (HS256 por defecto)
- `ACCESS_TOKEN_EXPIRE_MINUTES`

### Usuario admin por defecto (seed)
- Usuario: `admin`
- Clave: `Admin123!`
- Correo: `admin@example.com`

## 5) Proteccion de endpoints
- Todos los modulos de negocio principales se ejecutan autenticados via dependencia `Depends(get_current_user)`.
- En caso de token invalido o expirado, la API responde `401 Unauthorized`.

Observacion actual:
- El endpoint `POST /api/v1/personas/` no exige autenticacion en su implementacion actual.
- Esto puede ser intencional (registro) o un ajuste pendiente de endurecimiento segun politica del curso.

## 6) Contrato HTTP y validaciones
Patron aplicado en routers:
- `POST` retorna `201`.
- `GET` lista/detalle retorna `200`.
- `PUT` retorna `200`.
- `DELETE` retorna `204`.
- No encontrado retorna `404`.
- Validaciones de integridad y payload retornan `400`/`422` segun caso.

## 7) CORS y entorno
CORS permitido para frontend web local:
- `http://localhost:8080`
- `http://127.0.0.1:8080`

Variables de BD y seguridad se configuran en `docker-compose.yml` y/o entorno.

## 8) Pruebas backend
Suite actual en carpeta `tests/`:
- auth
- persona
- tipo_rol
- rol
- proyecto
- trabajo_grado
- producto
- contrato
- institucion
- proyecto_persona
- trabajo_persona
- proyecto_producto
- producto_trabajo

Estrategia de pruebas:
- Se crea `TEST_SCHEMA` (por defecto `proyecto_test`).
- Antes de cada test se reconstruye schema y se aplican `init/001_schema.sql` + `init/002_seed.sql`.
- No se modifica el schema operativo `proyecto`.

## 9) Pendientes identificados
- Definir explicitamente la politica de seguridad para `POST /personas/`.
- Agregar CI automatizada de pruebas (pipeline).
- Considerar migraciones versionadas (Alembic) para evolucion de schema.
