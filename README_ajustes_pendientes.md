# README - Ajustes pendientes del proyecto

Este documento resume únicamente lo que sigue abierto o parcialmente abierto después de los últimos cambios.

## Objetivo

Dejar organizados los ajustes que todavía faltan en la aplicación, con foco en GitHub y en la última capa de automatización del flujo de README.

## Estado de los ajustes previos

Ya quedó completado:

- agregar contratos en el sidebar,
- agregar `tipo` en proyecto,
- agregar `codigo_proyecto`,
- crear tabla de instituciones,
- crear tablas intermedias `proyecto_institucion` y `persona_institucion`,
- corregir el error al eliminar roles.

## Pendientes reales

### 1. Verificacion final del flujo GitHub / README por persona

El flujo ya quedo implementado con:

- un repositorio por proyecto,
- carpeta por persona derivada de `documento` + nombre,
- README publicado en ruta anidada por persona,
- enlace OSF como campo manual,
- template y vista previa alineados.

Lo que falta es solo validacion final en entorno real con credenciales y repositorios de GitHub.

## Prioridad sugerida

1. Ejecutar una validacion completa en GitHub con un proyecto real.
2. Confirmar que la ruta anidada se publica correctamente en un repo nuevo.

## Resultado esperado

Con esa verificacion, el flujo de README quedara cerrado y listo para uso normal.
