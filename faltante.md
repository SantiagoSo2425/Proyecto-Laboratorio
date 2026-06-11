# README — Flujo GitHub / README del proyecto

Este documento define el flujo necesario para publicar información del proyecto en GitHub de forma ordenada, con un repositorio por proyecto y una carpeta por usuario, incluyendo el enlace a OSF cuando aplique [file:10].

## Objetivo

Organizar el flujo de publicación para que cada proyecto tenga su propio repositorio y cada usuario tenga su carpeta con un README generado automáticamente o semiautomáticamente [file:10].

## Qué se necesita

### 1. Un repositorio por proyecto

Cada proyecto debe tener su propio repositorio en GitHub. Esto permite separar la documentación y la información generada para no mezclar proyectos distintos [file:10].

### 2. Una carpeta por usuario

Dentro de cada repositorio, debe existir una carpeta por usuario. Si la carpeta no existe, el sistema debe crearla antes de guardar el contenido [file:10].

### 3. README por usuario

Cada carpeta debe incluir un archivo `README.md` con la información del usuario o del aporte asociado al proyecto. Ese README debe incluir al menos:

- Nombre del proyecto.
- Personas asociadas.
- Productos.
- Trabajo de grado.
- Directores.
- Enlace a OSF, si existe [file:10].

### 4. Convención de nombres

Para evitar duplicados, se debe definir una convención única para nombrar carpetas y repositorios. Esa convención debe ser estable para que el sistema pueda verificar si ya existe la carpeta del usuario antes de crearla [file:10].

### 5. Enlace con OSF

OSF debe aparecer como un enlace de referencia dentro del README generado. El flujo debe permitir dejar el campo listo para que luego se publique o se conecte de forma más automática [file:10].

## Flujo propuesto

1. Se selecciona o crea un proyecto.
2. Se genera el nombre del repositorio para ese proyecto.
3. Se identifica el usuario al que corresponde la documentación.
4. Se verifica si la carpeta del usuario existe en el repositorio.
5. Si no existe, se crea la carpeta.
6. Se genera el `README.md` dentro de esa carpeta.
7. Se incluyen los datos del proyecto y el enlace a OSF si aplica [file:10].

## Reglas mínimas

- No duplicar carpetas de usuario.
- No sobrescribir información sin validación.
- Mantener el formato del README consistente.
- Usar una convención única de nombres para repositorios y carpetas [file:10].

## Qué falta definir

Todavía hace falta cerrar exactamente cómo se generará el enlace a OSF y cuál será la convención final de nombres para carpetas y repositorios [file:10].

## Resultado esperado

Con este flujo, el proyecto podrá publicar su información en GitHub de una forma ordenada, repetible y fácil de mantener, evitando duplicados y dejando listo el espacio para integrar OSF [file:10].







1. Regla exacta para nombrar repo y carpeta de usuario

Propongo una convención única y estable:

Repositorio: codigo-proyecto-nombre-proyecto en minúsculas y con guiones.

Carpeta de usuario: apellido-nombre o usuario-normalizado, también en minúsculas y con guiones.

La idea es que el nombre sea fácil de validar, evitar duplicados y que el sistema pueda crear la carpeta solo si no existe.

2. OSF en el generador

Por ahora, OSF debe ir como campo manual en el generador.
Eso es lo más práctico porque todavía no existe una integración real con OSF en el flujo, y además en OSF los metadatos suelen completarse de forma explícita por proyecto.

## Estado de implementacion

Estas dos decisiones ya quedaron aplicadas en el codigo:

- el repositorio sigue viniendo del proyecto, pero la carpeta y la publicacion se derivan de la persona seleccionada con `documento + nombre`,
- OSF se captura como campo manual en el generador y se publica como enlace dentro del README.
