# README Service

Microservicio independiente en FastAPI para generar, leer y publicar `README.md` en GitHub.

## Funcionalidades

- Listar repositorios de un usuario u organizacion.
- Obtener el `README.md` actual de un repositorio.
- Generar markdown desde una plantilla base parametrizable.
- Publicar o actualizar `README.md` en GitHub.
- Exponer una API separada del backend principal.

## Endpoints

- `GET /repos`
- `GET /repos/{owner}/{repo}/readme`
- `POST /repos/{owner}/{repo}/readme`
- `GET /readme/template`
- `POST /readme/generate`

## Variables de entorno

- `APP_NAME`
- `APP_ENV`
- `CORS_ORIGINS`
- `GITHUB_API_BASE_URL`

## Ejecucion local

```bash
cd readme_service
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

## Docker

Se levanta junto al resto del proyecto desde `docker compose up -d --build`.