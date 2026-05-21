import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto_trabajo.dart';
import '../models/trabajo_grado.dart';
import '../models/trabajo_persona.dart';
import '../providers/persona_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/producto_trabajo_provider.dart';
import '../providers/proyecto_provider.dart';
import '../providers/rol_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../providers/trabajo_persona_provider.dart';
import '../widgets/section_header.dart';

class WorkDegreeDetailScreen extends StatefulWidget {
  final TrabajoGrado trabajo;

  const WorkDegreeDetailScreen({super.key, required this.trabajo});

  @override
  State<WorkDegreeDetailScreen> createState() => _WorkDegreeDetailScreenState();
}

class _WorkDegreeDetailScreenState extends State<WorkDegreeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<TrabajoGradoProvider>().load(),
      context.read<TrabajoPersonaProvider>().load(),
      context.read<ProductoTrabajoProvider>().load(),
      context.read<PersonaProvider>().load(),
      context.read<RolProvider>().load(),
      context.read<ProductoProvider>().load(),
      context.read<ProyectoProvider>().load(),
    ]);
  }

  Future<void> _showTrabajoPersonaDialog({TrabajoPersona? initial}) async {
    final personas = context.read<PersonaProvider>().personas;
    final roles = context.read<RolProvider>().roles;
    if (personas.isEmpty || roles.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener personas y roles disponibles.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? personaId = initial?.idPersona;
    int? rolId = initial?.idRol;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Agregar persona al trabajo' : 'Editar relacion persona'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: personaId,
                    decoration: const InputDecoration(labelText: 'Persona'),
                    items: personas
                        .map(
                          (persona) => DropdownMenuItem(
                            value: persona.idPersona,
                            child: Text('${persona.nombre} - ${persona.documento}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setDialogState(() => personaId = value),
                    validator: (value) => value == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: rolId,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: roles
                        .map(
                          (rol) => DropdownMenuItem(
                            value: rol.idRol,
                            child: Text(rol.tipo),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setDialogState(() => rolId = value),
                    validator: (value) => value == null ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final provider = context.read<TrabajoPersonaProvider>();
                final success = initial == null
                    ? await provider.create(
                        idTrabajo: widget.trabajo.idTrabajo,
                        idPersona: personaId!,
                        idRol: rolId!,
                      )
                    : await provider.update(
                        id: initial.id,
                        idTrabajo: widget.trabajo.idTrabajo,
                        idPersona: personaId!,
                        idRol: rolId!,
                      );

                if (!mounted) {
                  return;
                }
                Navigator.pop(dialogContext, success);
              },
              child: Text(initial == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (ok != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la relacion.')),
      );
    }
  }

  Future<void> _deleteTrabajoPersona(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar relacion'),
        content: const Text('Deseas quitar esta persona del trabajo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await context.read<TrabajoPersonaProvider>().delete(id);
  }

  Future<void> _showProductoTrabajoDialog({ProductoTrabajo? initial}) async {
    final productos = context.read<ProductoProvider>().productos;
    if (productos.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener productos disponibles.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? productoId = initial?.idProducto;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Agregar producto al trabajo' : 'Editar relacion producto'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: DropdownButtonFormField<int>(
                value: productoId,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: productos
                    .map(
                      (producto) => DropdownMenuItem(
                        value: producto.idProducto,
                        child: Text(producto.descripcion),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => productoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final provider = context.read<ProductoTrabajoProvider>();
                final success = initial == null
                    ? await provider.create(
                        idTrabajo: widget.trabajo.idTrabajo,
                        idProducto: productoId!,
                      )
                    : await provider.update(
                        id: initial.id,
                        idTrabajo: widget.trabajo.idTrabajo,
                        idProducto: productoId!,
                      );

                if (!mounted) {
                  return;
                }
                Navigator.pop(dialogContext, success);
              },
              child: Text(initial == null ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );

    if (ok != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la relacion.')),
      );
    }
  }

  Future<void> _deleteProductoTrabajo(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar relacion'),
        content: const Text('Deseas quitar este producto del trabajo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await context.read<ProductoTrabajoProvider>().delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final proyectoProvider = context.watch<ProyectoProvider>();
    final trabajoPersonaProvider = context.watch<TrabajoPersonaProvider>();
    final productoTrabajoProvider = context.watch<ProductoTrabajoProvider>();
    final personaProvider = context.watch<PersonaProvider>();
    final rolProvider = context.watch<RolProvider>();
    final productoProvider = context.watch<ProductoProvider>();

    final relacionesPersona = trabajoPersonaProvider.relaciones
        .where((item) => item.idTrabajo == widget.trabajo.idTrabajo)
        .toList();
    final relacionesProducto = productoTrabajoProvider.relaciones
        .where((item) => item.idTrabajo == widget.trabajo.idTrabajo)
        .toList();
    final proyecto = proyectoProvider.proyectos
        .where((item) => item.idProyecto == widget.trabajo.idProyecto)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text('Trabajo ${widget.trabajo.idTrabajo}')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.trabajo.nombre, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('ID trabajo: ${widget.trabajo.idTrabajo}'),
                    Text('Proyecto: ${widget.trabajo.idProyecto} - ${proyecto?.nombre ?? 'Sin nombre'}'),
                    Text('Facultad: ${widget.trabajo.facultad}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Personas asociadas'),
                ElevatedButton.icon(
                  onPressed: () => _showTrabajoPersonaDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (trabajoPersonaProvider.isLoading && trabajoPersonaProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (relacionesPersona.isEmpty)
              const ListTile(
                title: Text('Sin personas asociadas'),
                subtitle: Text('Usa Agregar para asignar una persona y su rol.'),
              ),
            ...relacionesPersona.map((relacion) {
              final persona = personaProvider.personas.where((p) => p.idPersona == relacion.idPersona).firstOrNull;
              final rol = rolProvider.roles.where((r) => r.idRol == relacion.idRol).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(persona?.nombre ?? 'Persona ${relacion.idPersona}'),
                  subtitle: Text('Rol: ${rol?.tipo ?? relacion.idRol}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTrabajoPersonaDialog(initial: relacion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTrabajoPersona(relacion.id),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Productos asociados'),
                ElevatedButton.icon(
                  onPressed: () => _showProductoTrabajoDialog(),
                  icon: const Icon(Icons.add_box),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (productoTrabajoProvider.isLoading && productoTrabajoProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (relacionesProducto.isEmpty)
              const ListTile(
                title: Text('Sin productos asociados'),
                subtitle: Text('Usa Agregar para asociar productos a este trabajo.'),
              ),
            ...relacionesProducto.map((relacion) {
              final producto =
                  productoProvider.productos.where((p) => p.idProducto == relacion.idProducto).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(producto?.descripcion ?? 'Producto ${relacion.idProducto}'),
                  subtitle: Text('ID relacion: ${relacion.id}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProductoTrabajoDialog(initial: relacion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProductoTrabajo(relacion.id),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}