# Proyecto Laboratorio - Fullstack

Backend en FastAPI + frontend Flutter Web.

## Stack

- FastAPI
- PostgreSQL
- SQLAlchemy (ORM)
- Pydantic v2
- JWT (python-jose)
- Docker Compose

## Requisitos

- Docker + Docker Compose (para levantar todo)
- Python 3.11+ (para ejecutar pruebas desde el host)

## Levantar local (Docker Compose)

```bash
docker compose up -d --build
```

- API: http://localhost:8000
- Docs: http://localhost:8000/docs
- Health: http://localhost:8000/health
- Frontend: http://localhost:8080

## Inicio rapido (GitHub)

```bash
git clone <URL_DEL_REPO>
cd Proyecto\ Laboratorio
docker compose up -d --build
```

## Entrar a PostgreSQL

```bash
docker exec -it proyecto_postgres psql -U proyecto_user -d proyecto_db
```

## Variables de entorno

Se usan variables desde `docker-compose.yml`. Para ejecucion local fuera de Docker, puedes exportar:

```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=proyecto_db
DB_USER=proyecto_user
DB_PASSWORD=proyecto_pass
SECRET_KEY=change_this_in_prod
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

Variables para pruebas (opcional, por defecto usan las anteriores):

```bash
TEST_DB_HOST=localhost
TEST_DB_PORT=5432
TEST_DB_NAME=proyecto_db
TEST_DB_USER=proyecto_user
TEST_DB_PASSWORD=proyecto_pass
TEST_SCHEMA=proyecto_test
```

Variables para frontend (Docker build):

```bash
API_BASE_URL=http://localhost:8000/api/v1
```

## Datos semilla (seeds)

Los seeds se cargan automaticamente al crear la base por primera vez con Docker Compose.
El script esta en `init/002_seed.sql` y depende de `init/001_schema.sql`.

Usuario admin por defecto:
- usuario: admin
- clave: Admin123!
- correo: admin@example.com

Datos semilla cargados (al primer arranque limpio):
- tipo_rol: 2
- rol: 2
- persona: 2
- proyecto: 1
- contrato: 2
- proyecto_persona: 2
- trabajo_grado: 1
- trabajo_persona: 1
- producto: 1
- proyecto_producto: 1
- producto_trabajo: 1

Validaciones realizadas:
- El esquema `proyecto` existe y contiene todas las tablas.
- El login `admin` / `Admin123!` genera JWT correctamente.
- Los seeds solo se cargan en el primer arranque con volumen limpio.
- La ruta `/api/v1/personas/` coincide con el router.

Para resetear la base y recargar seeds:

```bash
docker compose down -v
docker compose up -d
```

## Probar login y consultas basicas

1) Login JWT:

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
	-H "Content-Type: application/x-www-form-urlencoded" \
	-d "username=admin&password=Admin123!"
```

2) Consultar personas (reemplaza TOKEN):

```bash
curl -X GET "http://localhost:8000/api/v1/personas/?skip=0&limit=100" \
	-H "Authorization: Bearer TOKEN"
```

## Endpoints principales

- POST /api/v1/auth/login
- GET /api/v1/personas/
- GET /api/v1/proyectos/
- GET /api/v1/trabajos-grado/
- GET /api/v1/productos/
- GET /api/v1/roles/
- GET /api/v1/tipos-rol/
- GET /api/v1/contratos/
- GET /api/v1/proyecto-personas/
- GET /api/v1/trabajo-personas/
- GET /api/v1/proyecto-productos/
- GET /api/v1/producto-trabajos/

## Frontend Flutter Web

El frontend vive en `flutter_app/` y se compila dentro de Docker.
La URL base del backend se inyecta en build con `API_BASE_URL`.

Autenticacion:
- El JWT se guarda en el navegador con `shared_preferences`.
- Si el token expira o es invalido, se cierra sesion automaticamente.

Si necesitas reconstruir el frontend:

```bash
docker compose build frontend
docker compose up -d frontend
```

Desarrollo local (opcional, sin Docker):

```bash
cd flutter_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

## CORS

El backend permite solicitudes desde:
- http://localhost:8080
- http://127.0.0.1:8080

## Pruebas automaticas (pytest)

Requisitos:
- Postgres levantado (docker compose up -d)
- Python con dependencias de desarrollo

Instalar dependencias:

```bash
pip install -r requirements-dev.txt
```

Ejecutar tests:

```bash
pytest -q
```

Notas:
- Los tests usan el schema `proyecto_test` dentro de la misma BD.
- Cada test recrea el schema y aplica `init/001_schema.sql` + `init/002_seed.sql`.
- No se modifica el schema `proyecto`.

Resultado esperado:
- 47 tests OK (segun la suite actual).

## Estructura

- app/
- flutter_app/
- tests/
- docker-compose.yml
- init/001_schema.sql
- init/002_seed.sql
- main.py
- requirements.txt
- requirements-dev.txt
- LICENSE
- CONTRIBUTING.md
