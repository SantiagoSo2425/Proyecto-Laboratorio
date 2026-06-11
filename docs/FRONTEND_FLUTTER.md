# Documentacion del Frontend Flutter Web

## 1) Vision general
El frontend fue implementado en Flutter Web con arquitectura por capas simples:
- `models`: representaciones de entidades.
- `services`: llamadas HTTP a la API.
- `providers`: estado, orquestacion y manejo de sesion.
- `screens`: UI (listas, formularios, detalle).
- `widgets`: componentes reutilizables.

## 2) Flujo de autenticacion y sesion
1. Login en `login_screen.dart` usando `AuthProvider`.
2. `AuthService` llama `POST /auth/login` y obtiene JWT.
3. Token se guarda en `shared_preferences`.
4. `main.dart` muestra `HomeScreen` si `auth.isAuthenticated`; de lo contrario, `LoginScreen`.
5. Si cualquier service recibe 401, lanza `UnauthorizedException`.
6. El provider captura esa excepcion y ejecuta `auth.logout()`.
7. Al quedar sin token, la app vuelve automaticamente a login.

## 3) Menu principal y enfoque UX actual
Menu lateral visible para usuario final:
- Inicio
- Personas
- Proyectos
- Trabajos de grado
- Instituciones
- Contratos
- Tipos de rol
- Roles
- Productos

Las relaciones tecnicas ya no aparecen como modulos de menu principal.

## 4) Pantallas principales
- `home_screen.dart`
- `login_screen.dart`
- `personas_screen.dart`
- `project_list_screen.dart`
- `work_degree_list_screen.dart`
- `institucion_list_screen.dart`
- `contrato_list_screen.dart`
- `readme_generator_screen.dart`
- Catalogos: `tipo_rol_list_screen.dart`, `rol_list_screen.dart`, `producto_list_screen.dart`

## 5) Detalles con relaciones embebidas
### Proyecto (`project_detail_screen.dart`)
Incluye:
- Datos base del proyecto.
- Tipo de proyecto.
- Instituciones asociadas.
- Personas asociadas (rol, horas, fechas).
- Productos asociados.
- Contratos proyecto-persona.

Acciones de relaciones:
- Alta/edicion/baja dentro de la misma pantalla.
- Formularios en `AlertDialog`.
- Dropdowns cargados desde providers (`PersonaProvider`, `RolProvider`, `ProductoProvider`, `ContratoProvider`).

### Trabajo de grado (`work_degree_detail_screen.dart`)
Incluye:
- Datos base del trabajo.
- Personas del trabajo y su rol.
- Productos asociados al trabajo.

### Persona (`persona_detail_screen.dart`)
Incluye:
- Datos base de persona.
- Instituciones asociadas.
- Proyectos donde participa (rol, horas, fechas).
- Trabajos de grado donde participa.

## 6) Manejo de formularios y dropdowns
Patron aplicado:
- Antes de mostrar dialogo, se valida que existan datos para poblar dropdown.
- Si falta catalogo necesario, se informa por `SnackBar`.
- Se valida formulario con `Form` + `GlobalKey<FormState>`.
- Al confirmar, se ejecuta `create/update` del provider y luego recarga estado.

## 7) Estados vacios y mensajes
Las pantallas de detalle muestran estado vacio explicito en cada seccion:
- Sin personas asociadas
- Sin productos asociados
- Sin contratos asociados
- Sin participacion en proyectos/trabajos

Esto mejora legibilidad para evaluacion funcional.

## 8) Modulos frontend implementados y estado
Estado actual:
- Auth (login/logout, persistencia token): Implementado
- Personas (CRUD + cambio de clave): Implementado
- Instituciones (CRUD): Implementado
- Proyectos (CRUD + detalle embebido): Implementado
- Trabajos de grado (CRUD + detalle embebido): Implementado
- Productos (CRUD): Implementado
- Tipos de rol (CRUD): Implementado
- Roles (CRUD): Implementado
- Contratos (CRUD global + embebido en detalle de proyecto): Implementado
- Generador README: selector de persona del proyecto, ruta `documento+nombre`, creación de repositorio, publicación configurable y enlace OSF manual: Implementado
- Acceso al generador README visible en menu con aviso, pero flujo real desde detalle de proyecto: Implementado
- Relaciones Proyecto-Persona: Implementado (embebido)
- Relaciones Proyecto-Producto: Implementado (embebido)
- Relaciones Trabajo-Persona: Implementado (embebido)
- Relaciones Producto-Trabajo: Implementado (embebido)
- Relaciones Proyecto-Institucion: Implementado desde formulario/detalle
- Relaciones Persona-Institucion: Implementado desde formulario/detalle

## 9) Pendientes frontend
- Persisten pantallas legacy de relaciones en codigo (`*_list_screen` y `*_form_screen`) aunque ya no son navegables desde menu principal.
- No existe suite formal de pruebas automatizadas de UI/integracion Flutter en el repositorio actual.
- No hay tema visual avanzado ni sistema de diseno formal; se usa estilo Material por defecto.

## 10) Ejecucion local del frontend
### Con Docker Compose (recomendado)
Se construye y expone en:
- `http://localhost:8080`

### Desarrollo local Flutter (opcional)
1. `cd flutter_app`
2. `flutter pub get`
3. `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api/v1`
