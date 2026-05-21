import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proyecto.dart';
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
  final _nombreController = TextEditingController();
  final _entidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _idController.text = initial.idProyecto;
      _nombreController.text = initial.nombre;
      _entidadController.text = initial.entidadFinanciadora;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
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
            nombre: _nombreController.text.trim(),
            entidadFinanciadora: _entidadController.text.trim(),
          )
        : await provider.update(
            idProyecto: _idController.text.trim(),
            nombre: _nombreController.text.trim(),
            entidadFinanciadora: _entidadController.text.trim(),
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
