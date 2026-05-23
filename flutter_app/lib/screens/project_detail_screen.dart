import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contrato.dart';
import '../models/proyecto.dart';
import '../models/proyecto_persona.dart';
import '../models/proyecto_producto.dart';
import '../models/readme_draft.dart';
import '../providers/contrato_provider.dart';
import '../providers/persona_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/proyecto_persona_provider.dart';
import '../providers/proyecto_producto_provider.dart';
import '../providers/proyecto_provider.dart';
import '../providers/rol_provider.dart';
import 'readme_generator_screen.dart';
import '../widgets/section_header.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Proyecto proyecto;

  const ProjectDetailScreen({super.key, required this.proyecto});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ProyectoProvider>().load(),
      context.read<ProyectoPersonaProvider>().load(),
      context.read<ProyectoProductoProvider>().load(),
      context.read<ContratoProvider>().load(),
      context.read<PersonaProvider>().load(),
      context.read<RolProvider>().load(),
      context.read<ProductoProvider>().load(),
    ]);
  }

  String _fmtDate(DateTime value) {
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '${value.year}-$m-$d';
  }

  Future<void> _showProyectoPersonaDialog({ProyectoPersona? initial}) async {
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
    int? personaId = initial?.personaId;
    int? rolId = initial?.idRol;
    final horasController = TextEditingController(text: initial?.horasSemanales.toString() ?? '');
    DateTime? fechaInicio = initial?.fechaInicio;
    DateTime? fechaFin = initial?.fechaFin;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickInicio() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: fechaInicio ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setDialogState(() {
                  fechaInicio = picked;
                  if (fechaFin != null && fechaFin!.isBefore(fechaInicio!)) {
                    fechaFin = null;
                  }
                });
              }
            }

            Future<void> pickFin() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: fechaFin ?? fechaInicio ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setDialogState(() => fechaFin = picked);
              }
            }

            return AlertDialog(
              title: Text(initial == null ? 'Agregar persona al proyecto' : 'Editar relacion persona'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: horasController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Horas semanales'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'Numero invalido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Fecha inicio'),
                          subtitle: Text(fechaInicio == null ? 'Seleccionar fecha' : _fmtDate(fechaInicio!)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: pickInicio,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Fecha fin (opcional)'),
                          subtitle: Text(fechaFin == null ? 'Sin fecha fin' : _fmtDate(fechaFin!)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: pickFin,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setDialogState(() => fechaFin = null),
                            child: const Text('Limpiar fecha fin'),
                          ),
                        ),
                      ],
                    ),
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
                    if (!formKey.currentState!.validate() || fechaInicio == null) {
                      return;
                    }

                    final provider = context.read<ProyectoPersonaProvider>();
                    final horas = int.parse(horasController.text.trim());
                    final success = initial == null
                        ? await provider.create(
                            idProyecto: widget.proyecto.idProyecto,
                            personaId: personaId!,
                            idRol: rolId!,
                            horasSemanales: horas,
                            fechaInicio: fechaInicio!,
                            fechaFin: fechaFin,
                          )
                        : await provider.update(
                            id: initial.id,
                            idProyecto: widget.proyecto.idProyecto,
                            personaId: personaId!,
                            idRol: rolId!,
                            horasSemanales: horas,
                            fechaInicio: fechaInicio!,
                            fechaFin: fechaFin,
                          );

                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(dialogContext, success);
                  },
                  child: Text(initial == null ? 'Agregar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    horasController.dispose();

    if (ok != true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la relacion.')),
      );
    }
  }

  Future<void> _deleteProyectoPersona(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar relacion'),
        content: const Text('Deseas quitar esta persona del proyecto?'),
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
    await context.read<ProyectoPersonaProvider>().delete(id);
  }

  Future<void> _showProyectoProductoDialog({ProyectoProducto? initial}) async {
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
          title: Text(initial == null ? 'Agregar producto al proyecto' : 'Editar relacion producto'),
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
                final provider = context.read<ProyectoProductoProvider>();
                final success = initial == null
                    ? await provider.create(
                        idProyecto: widget.proyecto.idProyecto,
                        idProducto: productoId!,
                      )
                    : await provider.update(
                        id: initial.id,
                        idProyecto: widget.proyecto.idProyecto,
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

  Future<void> _deleteProyectoProducto(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar relacion'),
        content: const Text('Deseas quitar este producto del proyecto?'),
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
    await context.read<ProyectoProductoProvider>().delete(id);
  }

  Future<void> _showContratoDialog({Contrato? initial}) async {
    final personas = context.read<PersonaProvider>().personas;
    if (personas.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener personas disponibles.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? personaId = initial?.idPersona;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(initial == null ? 'Agregar contrato' : 'Editar contrato'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: DropdownButtonFormField<int>(
                value: personaId,
                decoration: const InputDecoration(labelText: 'Persona contratada'),
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
                final provider = context.read<ContratoProvider>();
                final success = initial == null
                    ? await provider.create(
                        idProyecto: widget.proyecto.idProyecto,
                        idPersona: personaId!,
                      )
                    : await provider.update(
                        id: initial.id,
                        idProyecto: widget.proyecto.idProyecto,
                        idPersona: personaId!,
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
        const SnackBar(content: Text('No se pudo guardar el contrato.')),
      );
    }
  }

  Future<void> _deleteContrato(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contrato'),
        content: const Text('Deseas eliminar este contrato del proyecto?'),
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
    await context.read<ContratoProvider>().delete(id);
  }

  ReadmeDraft _buildReadmeDraft({
    required List<ProyectoPersona> relacionesPersona,
    required List<Contrato> contratosDelProyecto,
    required PersonaProvider personaProvider,
    required RolProvider rolProvider,
  }) {
    final participants = relacionesPersona.map((relacion) {
      final persona = personaProvider.personas.where((item) => item.idPersona == relacion.personaId).firstOrNull;
      final rol = rolProvider.roles.where((item) => item.idRol == relacion.idRol).firstOrNull;
      final hasContrato = contratosDelProyecto.any((item) => item.idPersona == relacion.personaId);

      return ReadmeParticipantDraft(
        name: persona?.nombre ?? 'Persona ${relacion.personaId}',
        role: rol?.tipo ?? 'Rol ${relacion.idRol}',
        contract: hasContrato ? 'Contrato asociado al proyecto' : '',
        dedication: '${relacion.horasSemanales} h/semana',
        contribution: '',
      );
    }).toList();

    return ReadmeDraft.forProject(
      projectTitle: widget.proyecto.nombre,
      participants: participants,
    );
  }

  @override
  Widget build(BuildContext context) {
    final proyectoPersonaProvider = context.watch<ProyectoPersonaProvider>();
    final proyectoProductoProvider = context.watch<ProyectoProductoProvider>();
    final contratoProvider = context.watch<ContratoProvider>();
    final personaProvider = context.watch<PersonaProvider>();
    final rolProvider = context.watch<RolProvider>();
    final productoProvider = context.watch<ProductoProvider>();

    final relacionesPersona = proyectoPersonaProvider.relaciones
        .where((item) => item.idProyecto == widget.proyecto.idProyecto)
        .toList();
    final relacionesProducto = proyectoProductoProvider.relaciones
        .where((item) => item.idProyecto == widget.proyecto.idProyecto)
        .toList();
    final contratosDelProyecto = contratoProvider.contratos
      .where((item) => item.idProyecto == widget.proyecto.idProyecto)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Proyecto ${widget.proyecto.idProyecto}')),
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
                    Text(widget.proyecto.nombre, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('ID: ${widget.proyecto.idProyecto}'),
                    Text('Entidad financiadora: ${widget.proyecto.entidadFinanciadora}'),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final draft = _buildReadmeDraft(
                            relacionesPersona: relacionesPersona,
                            contratosDelProyecto: contratosDelProyecto,
                            personaProvider: personaProvider,
                            rolProvider: rolProvider,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReadmeGeneratorScreen(initialDraft: draft),
                            ),
                          );
                        },
                        icon: const Icon(Icons.description),
                        label: const Text('Generar README'),
                      ),
                    ),
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
                  onPressed: () => _showProyectoPersonaDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (proyectoPersonaProvider.isLoading && proyectoPersonaProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (relacionesPersona.isEmpty)
              const ListTile(
                title: Text('Sin personas asociadas'),
                subtitle: Text('Usa Agregar para asignar persona, rol, horas y fechas.'),
              ),
            ...relacionesPersona.map((relacion) {
              final persona = personaProvider.personas.where((p) => p.idPersona == relacion.personaId).firstOrNull;
              final rol = rolProvider.roles.where((r) => r.idRol == relacion.idRol).firstOrNull;
              final fechaFinText = relacion.fechaFin == null ? 'Sin fecha fin' : _fmtDate(relacion.fechaFin!);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(persona?.nombre ?? 'Persona ${relacion.personaId}'),
                  subtitle: Text(
                    'Rol: ${rol?.tipo ?? relacion.idRol} | Horas: ${relacion.horasSemanales}\n'
                    'Inicio: ${_fmtDate(relacion.fechaInicio)} | Fin: $fechaFinText',
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProyectoPersonaDialog(initial: relacion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProyectoPersona(relacion.id),
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
                  onPressed: () => _showProyectoProductoDialog(),
                  icon: const Icon(Icons.add_box),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (proyectoProductoProvider.isLoading && proyectoProductoProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (relacionesProducto.isEmpty)
              const ListTile(
                title: Text('Sin productos asociados'),
                subtitle: Text('Usa Agregar para asociar productos al proyecto.'),
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
                        onPressed: () => _showProyectoProductoDialog(initial: relacion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProyectoProducto(relacion.id),
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
                const SectionHeader(title: 'Contratos del proyecto'),
                ElevatedButton.icon(
                  onPressed: () => _showContratoDialog(),
                  icon: const Icon(Icons.assignment_add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            if (contratoProvider.isLoading && contratoProvider.contratos.isEmpty)
              const LinearProgressIndicator(),
            if (contratosDelProyecto.isEmpty)
              const ListTile(
                title: Text('Sin contratos asociados'),
                subtitle: Text('Usa Agregar para crear un contrato proyecto-persona.'),
              ),
            ...contratosDelProyecto.map((contrato) {
              final persona =
                  personaProvider.personas.where((item) => item.idPersona == contrato.idPersona).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(persona?.nombre ?? 'Persona ${contrato.idPersona}'),
                  subtitle: Text('ID contrato: ${contrato.id}'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showContratoDialog(initial: contrato),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteContrato(contrato.id),
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