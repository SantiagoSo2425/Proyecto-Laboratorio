import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trabajo_grado.dart';
import '../providers/proyecto_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../widgets/loading_view.dart';

class WorkDegreeFormScreen extends StatefulWidget {
  final TrabajoGrado? initial;

  const WorkDegreeFormScreen({super.key, this.initial});

  @override
  State<WorkDegreeFormScreen> createState() => _WorkDegreeFormScreenState();
}

class _WorkDegreeFormScreenState extends State<WorkDegreeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _facultadController = TextEditingController();
  String? _selectedProyectoId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _idController.text = initial.idTrabajo.toString();
      _selectedProyectoId = initial.idProyecto;
      _nombreController.text = initial.nombre;
      _facultadController.text = initial.facultad;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proyectoProvider = context.read<ProyectoProvider>();
      if (proyectoProvider.proyectos.isEmpty) {
        proyectoProvider.load();
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _nombreController.dispose();
    _facultadController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<TrabajoGradoProvider>();
    final isEdit = widget.initial != null;
    final proyectoId = _selectedProyectoId;

    if (proyectoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proyecto valido')),
      );
      return;
    }

    final ok = isEdit
        ? await provider.update(
            idTrabajo: int.parse(_idController.text.trim()),
            idProyecto: proyectoId,
            nombre: _nombreController.text.trim(),
            facultad: _facultadController.text.trim(),
          )
        : await provider.create(
            idProyecto: proyectoId,
            nombre: _nombreController.text.trim(),
            facultad: _facultadController.text.trim(),
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el trabajo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final proyectoProvider = context.watch<ProyectoProvider>();
    final proyectos = proyectoProvider.proyectos;
    final hasSelected = _selectedProyectoId != null &&
        proyectos.any((p) => p.idProyecto == _selectedProyectoId);
    final currentValue = hasSelected ? _selectedProyectoId : null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar trabajo de grado' : 'Nuevo trabajo de grado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (proyectoProvider.isLoading && proyectos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: LoadingView(),
                ),
              if (isEdit)
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'ID Trabajo'),
                  enabled: false,
                ),
              DropdownButtonFormField<String>(
                value: currentValue,
                decoration: const InputDecoration(labelText: 'Proyecto'),
                items: proyectos
                    .map(
                      (proyecto) => DropdownMenuItem(
                        value: proyecto.idProyecto,
                        child: Text('${proyecto.idProyecto} - ${proyecto.nombre}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedProyectoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!proyectoProvider.isLoading && proyectos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay proyectos disponibles. Crea un proyecto primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facultadController,
                decoration: const InputDecoration(labelText: 'Facultad'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
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
