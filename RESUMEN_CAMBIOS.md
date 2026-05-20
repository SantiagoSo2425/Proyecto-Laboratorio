# Resumen detallado de cambios - Proyecto Laboratorio

## Arquitectura propuesta (5 lineas)
1. Separacion por capas: api (routers), crud (datos), models (ORM), schemas (DTOs), security (JWT + hashing), core (config), db (sesion).
2. Configuracion centralizada con Pydantic Settings y variables de entorno.
3. SQLAlchemy moderno, esquema por defecto "proyecto" y search_path configurado en la conexion.
4. Autenticacion JWT con OAuth2PasswordBearer y login por usuario + clave.
5. Docker Compose con Postgres y API listos para ejecutar localmente.

## Arbol del proyecto generado
- app/
- app/api/
- app/api/deps.py
- app/api/router.py
- app/api/routers/
- app/api/routers/auth.py
- app/api/routers/contrato.py
- app/api/routers/persona.py
- app/api/routers/producto.py
- app/api/routers/producto_trabajo.py
- app/api/routers/proyecto.py
- app/api/routers/proyecto_persona.py
- app/api/routers/proyecto_producto.py
- app/api/routers/rol.py
- app/api/routers/tipo_rol.py
- app/api/routers/trabajo_grado.py
- app/api/routers/trabajo_persona.py
- app/core/
- app/core/config.py
- app/crud/
- app/crud/contrato.py
- app/crud/persona.py
- app/crud/producto.py
- app/crud/producto_trabajo.py
- app/crud/proyecto.py
- app/crud/proyecto_persona.py
- app/crud/proyecto_producto.py
- app/crud/rol.py
- app/crud/tipo_rol.py
- app/crud/trabajo_grado.py
- app/crud/trabajo_persona.py
- app/db/
- app/db/base.py
- app/db/session.py
- app/models/
- app/models/base.py
- app/models/contrato.py
- app/models/persona.py
- app/models/producto.py
- app/models/producto_trabajo.py
- app/models/proyecto.py
- app/models/proyecto_persona.py
- app/models/proyecto_producto.py
- app/models/rol.py
- app/models/tipo_rol.py
- app/models/trabajo_grado.py
- app/models/trabajo_persona.py
- app/schemas/
- app/schemas/auth.py
- app/schemas/contrato.py
- app/schemas/persona.py
- app/schemas/producto.py
- app/schemas/producto_trabajo.py
- app/schemas/proyecto.py
- app/schemas/proyecto_persona.py
- app/schemas/proyecto_producto.py
- app/schemas/rol.py
- app/schemas/tipo_rol.py
- app/schemas/trabajo_grado.py
- app/schemas/trabajo_persona.py
- app/security/
- app/security/jwt.py
- app/security/password.py
- init/001_schema.sql
- 001_schema.sql
- docker-compose.yml
- main.py
- requirements.txt
- README.md

## Docker Compose (api + postgres)
- Se agrego el servicio api con Python 3.11, instalacion de dependencias y arranque Uvicorn.
- Postgres 16 mantiene healthcheck, volumen persistente y script de init.
- Variables de entorno para BD y JWT listadas en el compose.

Contenido relevante:
```yaml
services:
  api:
    image: python:3.11-slim
    container_name: proyecto_api
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    working_dir: /app
    volumes:
      - ./:/app
    environment:
      APP_ENV: local
      DB_HOST: postgres
      DB_PORT: "5432"
      DB_NAME: proyecto_db
      DB_USER: proyecto_user
      DB_PASSWORD: proyecto_pass
      SECRET_KEY: "change_this_in_prod"
      ACCESS_TOKEN_EXPIRE_MINUTES: "60"
    command: >
      sh -c "pip install --no-cache-dir -r requirements.txt && \
      uvicorn main:app --host 0.0.0.0 --port 8000 --reload"
    ports:
      - "8000:8000"

  postgres:
    image: postgres:16
    container_name: proyecto_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: proyecto_db
      POSTGRES_USER: proyecto_user
      POSTGRES_PASSWORD: proyecto_pass
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U proyecto_user -d proyecto_db"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pgdata:
```

## SQL de inicializacion
- Se mantuvo el esquema proyecto y las tablas solicitadas.
- Se elimino persona_rol porque no estaba en requisitos y duplicaba relaciones.

Resumen de tablas finales:
```sql
CREATE SCHEMA IF NOT EXISTS proyecto;
SET search_path TO proyecto;

CREATE TABLE tipo_rol (...);
CREATE TABLE rol (...);
CREATE TABLE persona (...);
CREATE TABLE proyecto (...);
CREATE TABLE producto (...);
CREATE TABLE trabajo_grado (...);
CREATE TABLE proyecto_persona (...);
CREATE TABLE contrato (...);
CREATE TABLE trabajo_persona (...);
CREATE TABLE proyecto_producto (...);
CREATE TABLE producto_trabajo (...);
```

## Modelos ORM (SQLAlchemy moderno)
- Se definio Base con schema="proyecto".
- Se crearon modelos por entidad: tipo_rol, rol, persona, proyecto, producto, trabajo_grado,
  proyecto_persona, contrato, trabajo_persona, proyecto_producto, producto_trabajo.
- Se usaron ForeignKey segun el SQL y nombres consistentes con la BD.

## Schemas Pydantic v2
- Se agregaron schemas Create/Update/Read por cada entidad.
- Se incluyo Token para JWT.
- En persona se valida correo con EmailStr y la clave solo vive en Create/Update.

## CRUD por modulo
- CRUD basico por entidad: get, list_all, create, update, delete.
- Persona aplica hash a la clave al crear y actualizar.

## Routers por modulo
- Routers REST por entidad con endpoints CRUD.
- Se protegieron con JWT todas las rutas menos /auth/login.
- Se agrego el login OAuth2 con tokenUrl /api/v1/auth/login.

## Seguridad (JWT + hashing)
- Hashing con bcrypt via passlib.
- JWT con python-jose, exp configurable por ACCESS_TOKEN_EXPIRE_MINUTES.

## Configuracion y DB
- Settings centralizados en app/core/config.py.
- URL de BD calculada en Settings.
- Engine SQLAlchemy con search_path=proyecto.
- SessionLocal con autocommit/autoflush desactivados.

## main.py
- Se agrego FastAPI con api_router y endpoint /health.

## requirements.txt
- Se agregaron dependencias: fastapi, uvicorn, SQLAlchemy, psycopg2-binary,
  pydantic v2, pydantic-settings, python-jose, passlib[bcrypt], python-multipart.

## README.md
- Se documento el arranque con Docker Compose y los endpoints base.
- Se agrego la lista de variables de entorno y estructura del proyecto.

## Archivos agregados o actualizados
- docker-compose.yml
- init/001_schema.sql
- 001_schema.sql
- main.py
- requirements.txt
- README.md
- app/* (api, crud, models, schemas, security, core, db)

## Recomendaciones
- Cambiar SECRET_KEY en produccion.
- Si quieres versionado de BD, agregar Alembic.
