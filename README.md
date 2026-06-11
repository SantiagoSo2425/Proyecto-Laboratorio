# Proyecto Laboratorio (Backend FastAPI + Frontend Flutter Web)

Documentacion oficial del proyecto para evaluacion academica y uso tecnico.

## 1) Resumen ejecutivo
Proyecto fullstack para gestion de laboratorio con:
- Backend REST en FastAPI.
- Base de datos PostgreSQL.
- Frontend en Flutter Web.
- Autenticacion JWT.
- Docker Compose para ejecucion integral local.

## 2) Arquitectura general
Arquitectura por capas:
- Backend: `api -> crud -> models/schemas -> db/security/config`.
- Frontend: `screens -> providers -> services -> API`.
- Persistencia: PostgreSQL en esquema `proyecto`.
- Microservicio README: FastAPI independiente en `readme_service/` para generar y publicar `README.md` en GitHub.

Documentos tecnicos detallados:
- Backend: [docs/BACKEND.md](docs/BACKEND.md)
- Frontend Flutter: [docs/FRONTEND_FLUTTER.md](docs/FRONTEND_FLUTTER.md)
- Base de datos y relaciones: [docs/BASE_DATOS.md](docs/BASE_DATOS.md)

## 3) Estructura principal del repositorio
```text
.
├─ app/                     # Backend FastAPI (api, crud, models, schemas, security)
├─ flutter_app/             # Frontend Flutter Web
├─ readme_service/           # Microservicio FastAPI para README y GitHub
├─ init/                    # SQL de inicializacion (schema + seeds)
├─ tests/                   # Pruebas pytest del backend
├─ docker-compose.yml       # Orquestacion local
├─ main.py                  # Entrada backend
├─ requirements.txt
└─ requirements-dev.txt
```

## 4) Modulos implementados y estado actual
Estado funcional (backend + frontend):
- Auth JWT: Implementado
- Personas: Implementado
- Instituciones: Implementado
- Tipos de rol: Implementado
- Roles: Implementado
- Proyectos: Implementado
- Trabajos de grado: Implementado
- Productos: Implementado
- Contratos: Implementado
- Proyecto-Persona: Implementado
- Trabajo-Persona: Implementado
- Proyecto-Producto: Implementado
- Producto-Trabajo: Implementado

UI/UX actual:
- Relaciones tecnicas fuera del menu principal.
- Relaciones embebidas en pantallas de detalle (proyecto y trabajo), segun refactor reciente.
- Instituciones y contratos con administracion propia en el menu lateral.
- Los proyectos ahora manejan `codigo_proyecto` y lo usan como referencia principal para GitHub.
- El generador README ahora selecciona una persona del proyecto, usa `documento + nombre` para la carpeta y acepta enlace OSF manual.
- El acceso al generador README sigue visible en el menu, pero muestra un aviso y solo se usa desde el detalle de un proyecto.

## 5) Flujo de autenticacion JWT
1. `POST /api/v1/auth/login` con usuario/clave.
2. Respuesta con `access_token`.
3. Frontend guarda token en `shared_preferences`.
4. Services envian `Authorization: Bearer <token>`.
5. Si API responde 401, providers ejecutan logout.
6. La app vuelve a pantalla de login automaticamente.

Usuario admin por defecto (seed):
- Usuario: `admin`
- Clave: `Admin123!`
- Correo: `admin@example.com`

## 6) Seeds y datos de prueba
Archivos:
- Schema: `init/001_schema.sql`
- Seeds: `init/002_seed.sql`

Los seeds se aplican en inicializacion limpia del volumen de PostgreSQL.

Datos base incluidos:
- tipos de rol, roles
- personas (incluye admin)
- instituciones
- proyecto, trabajo de grado, producto
- relaciones: proyecto_persona, trabajo_persona, proyecto_producto, producto_trabajo
- relaciones N:M con instituciones
- contratos
- codigo de proyecto

## 7) Ejecucion local con Docker Compose
Requisitos:
- Docker
- Docker Compose

Levantar todo:
```bash
docker compose up -d --build
```

Servicios:
- Frontend: `http://localhost:8080`
- API: `http://localhost:8000`
- README service: `http://localhost:8001`
- Swagger: `http://localhost:8000/docs`
- Health: `http://localhost:8000/health`
- PostgreSQL: `localhost:5432`

## 8) Levantar todo desde cero y reset de base de datos
Reset completo (borra volumen de PostgreSQL):
```bash
docker compose down -v
docker compose up -d --build
```

Este flujo:
- recrea contenedores,
- recrea esquema `proyecto`,
- reaplica seeds.

## 9) Pruebas y validaciones realizadas
### Pruebas automatizadas backend
- Suite pytest en `tests/` para auth y CRUD de todos los modulos.
- Estrategia de test aislada con `TEST_SCHEMA` (default: `proyecto_test`).
- Cada test reconstruye schema y seeds de forma limpia.

Ejecucion:
```bash
pip install -r requirements-dev.txt
pytest -q
```

### Validaciones funcionales recientes (frontend)
- Relaciones embebidas en detalle de Proyecto/Trabajo/Persona.
- Dialogos de relacion con dropdowns y validaciones.
- Estados vacios con mensajes explicitos.
- Auditoria de JWT en services protegidos.
- Logout y retorno a login al detectar 401.

## 10) Pantallas principales y relaciones embebidas
Pantallas clave:
- Login
- Inicio
- Personas
- Proyectos
- Trabajos de grado
- Instituciones
- Contratos
- Catalogos: tipos de rol, roles, productos

Pantallas de detalle:
- Proyecto: personas, productos y contratos embebidos.
- Trabajo de grado: personas y productos embebidos.
- Persona: proyectos y trabajos donde participa.
- Proyecto y persona muestran instituciones asociadas.

## 11) Variables de entorno relevantes
Backend:
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `SECRET_KEY`, `ACCESS_TOKEN_EXPIRE_MINUTES`

Frontend (build/run):
- `API_BASE_URL` (por defecto `http://localhost:8000/api/v1`)

## 12) Pendientes identificados (sin inventar)
- No existe aun una suite automatizada de integracion/UI para Flutter en el repositorio.
- Persisten pantallas legacy de relaciones en codigo Flutter (ya no visibles en menu principal).
- Definir si `POST /api/v1/personas/` debe requerir autenticacion o permanecer como alta abierta.
- No hay migraciones versionadas (Alembic) para evolucion de esquema.

## 13) Enlaces utiles
- Guia backend: [docs/BACKEND.md](docs/BACKEND.md)
- Guia frontend: [docs/FRONTEND_FLUTTER.md](docs/FRONTEND_FLUTTER.md)
- Guia base de datos: [docs/BASE_DATOS.md](docs/BASE_DATOS.md)
- Contribucion: [CONTRIBUTING.md](CONTRIBUTING.md)
