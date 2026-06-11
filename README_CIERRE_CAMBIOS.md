# README de Cierre de Cambios

Este documento resume los cambios realizados en el proyecto para dejar el estado actual claro y facilitar la revision final.

## 1. Resumen general

Se ajusto el proyecto en tres frentes principales:

- Backend FastAPI y base de datos.
- Frontend Flutter Web.
- Microservicio `readme_service` para generar y publicar README en GitHub.

Ademas, se corrigieron errores reales de ejecucion que aparecieron en el contenedor de la API al trabajar con el esquema de PostgreSQL ya existente.

## 2. Cambios en backend

### 2.1 Esquema de datos

Se agregaron y normalizaron nuevas entidades y relaciones:

- `institucion`.
- `persona_institucion`.
- `proyecto_institucion`.
- `proyecto.codigo_proyecto`.
- `proyecto.tipo` con valores `investigacion` y `extension`.

Tambien se migro `persona.institucion` a una relacion N:M con instituciones.

### 2.2 CRUD y API

Se actualizaron los CRUD y routers para reflejar el nuevo esquema:

- CRUD de proyectos con `codigo_proyecto` e instituciones.
- CRUD de personas con instituciones asociadas.
- CRUD de contratos con soporte global y contextual.
- CRUD y router de instituciones.
- Manejo de `IntegrityError` en varios endpoints para devolver respuestas mas claras.
- Eliminacion de roles bloqueada cuando el rol esta en uso.

### 2.3 Arranque y correccion de la base existente

Se corrigio el problema real del contenedor de PostgreSQL, que tenia el esquema viejo montado en un volumen persistente.

Ahora `main.py`:

- crea el schema `proyecto` si no existe,
- crea tablas faltantes con `Base.metadata.create_all`,
- agrega columnas faltantes a `proyecto.proyecto`,
- rellena valores vacios de `codigo_proyecto` y `tipo`,
- asegura el indice/constraint necesarios para que el backend arranque con la base actual sin borrar datos.

## 3. Cambios en frontend Flutter

### 3.1 Modelos y servicios

Se actualizaron los modelos para reflejar el nuevo esquema:

- `Proyecto` ahora maneja `codigoProyecto`, `tipo` e instituciones.
- `Persona` ahora incluye instituciones asociadas.
- Se agrego soporte para instituciones y contratos.
- `ReadmeDraft` fue ampliado para manejar la generacion de README.

### 3.2 Pantallas y flujo funcional

Se implementaron o actualizaron pantallas para:

- instituciones,
- contratos,
- proyectos,
- personas,
- relaciones entre entidades,
- generador de README.

El flujo del generador README quedo mas completo:

- seleccion de repositorio,
- seleccion de persona del proyecto,
- ruta derivada de `documento + nombre`,
- campo manual para OSF,
- vista previa del README,
- publicacion en una ruta anidada dentro del repo.

## 4. Cambios en `readme_service`

Se extendio el microservicio para que pueda:

- listar repositorios,
- crear repositorios,
- leer README desde rutas anidadas,
- publicar README en una ruta configurable,
- generar markdown con datos del proyecto y de la persona seleccionada,
- incluir `OSF` como enlace manual.

La plantilla y la vista previa quedaron alineadas con el flujo actual.

## 5. Documentacion actualizada

Se actualizaron los documentos de referencia para reflejar el estado real del proyecto:

- `README.md`.
- `docs/BACKEND.md`.
- `docs/BASE_DATOS.md`.
- `docs/FRONTEND_FLUTTER.md`.
- `README_ajustes_pendientes.md`.
- `faltante.md`.
- `readme_service/README.md`.

## 6. Verificaciones realizadas

Se reviso y valido lo siguiente:

- compilacion de Python con `python -m compileall`.
- generacion de markdown del README con documento, instituciones y OSF.
- correccion de errores reales reportados por logs del contenedor.

## 7. Estado final

El proyecto quedo alineado con el flujo definido:

- un repositorio por proyecto,
- carpeta por persona seleccionada,
- carpeta derivada de `documento + nombre`,
- README con contexto del proyecto y datos de la persona,
- OSF como enlace manual,
- esquema de BD compatible con el contenedor actual.

## 8. Pendiente menor

Queda pendiente una validacion final en entorno real con credenciales de GitHub y un repositorio de prueba para confirmar la publicacion completa.
