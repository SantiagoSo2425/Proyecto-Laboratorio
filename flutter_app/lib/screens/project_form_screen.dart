import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proyecto.dart';
import '../providers/institucion_provider.dart';
import '../providers/proyecto_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  final Proyecto? initial;

  const ProjectFormScreen({super.key, this.initial});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _entidadController = TextEditingController();
  String _tipo = 'investigacion';
  final List<int> _selectedInstitucionIds = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _idController.text = initial.idProyecto;
      _codigoController.text = initial.codigoProyecto;
      _nombreController.text = initial.nombre;
      _entidadController.text = initial.entidadFinanciadora;
      _tipo = initial.tipo;
      _selectedInstitucionIds.addAll(initial.instituciones.map((item) => item.idInstitucion));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final institucionProvider = context.read<InstitucionProvider>();
      if (institucionProvider.instituciones.isEmpty) {
        institucionProvider.load();
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _codigoController.dispose();
    _nombreController.dispose();
    _entidadController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<ProyectoProvider>();
    final ok = widget.initial == null
        ? await provider.create(
            idProyecto: _idController.text.trim(),
            codigoProyecto: _codigoController.text.trim(),
            nombre: _nombreController.text.trim(),
            entidadFinanciadora: _entidadController.text.trim(),
            tipo: _tipo,
            institucionIds: _selectedInstitucionIds,
          )
        : await provider.update(
            idProyecto: _idController.text.trim(),
            codigoProyecto: _codigoController.text.trim(),
            nombre: _nombreController.text.trim(),
            entidadFinanciadora: _entidadController.text.trim(),
            tipo: _tipo,
            institucionIds: _selectedInstitucionIds,
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el proyecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final institucionProvider = context.watch<InstitucionProvider>();
    final instituciones = institucionProvider.instituciones;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar proyecto' : 'Nuevo proyecto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID Proyecto'),
                enabled: !isEdit,
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Codigo de proyecto'),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _entidadController,
                decoration: const InputDecoration(labelText: 'Entidad financiadora'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de proyecto'),
                items: const [
                  DropdownMenuItem(value: 'investigacion', child: Text('Investigacion')),
                  DropdownMenuItem(value: 'extension', child: Text('Extension')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipo = value);
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Text('Instituciones', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (institucionProvider.isLoading && instituciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
              if (!institucionProvider.isLoading && instituciones.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No hay instituciones disponibles. Crea una primero.'),
                ),
              if (instituciones.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: instituciones.map((institucion) {
                    final selected = _selectedInstitucionIds.contains(institucion.idInstitucion);
                    return FilterChip(
                      label: Text(institucion.nombre),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedInstitucionIds.add(institucion.idInstitucion);
                          } else {
                            _selectedInstitucionIds.remove(institucion.idInstitucion);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
