import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../providers/persona_provider.dart';

class PersonaFormScreen extends StatefulWidget {
  final Persona? initial;

  const PersonaFormScreen({super.key, this.initial});

  @override
  State<PersonaFormScreen> createState() => _PersonaFormScreenState();
}

class _PersonaFormScreenState extends State<PersonaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _programaController = TextEditingController();
  final _documentoController = TextEditingController();
  final _correoController = TextEditingController();
  final _institucionController = TextEditingController();
  final _nivelController = TextEditingController();
  final _semestreController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nombreController.text = initial.nombre;
      _programaController.text = initial.programa;
      _documentoController.text = initial.documento;
      _correoController.text = initial.correo;
      _institucionController.text = initial.institucion;
      _nivelController.text = initial.nivelAcademico;
      _semestreController.text = initial.semestre?.toString() ?? '';
      _usuarioController.text = initial.usuario;
      _activo = initial.activo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _programaController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _institucionController.dispose();
    _nivelController.dispose();
    _semestreController.dispose();
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<PersonaProvider>();
    final isEdit = widget.initial != null;

    final data = {
      'nombre': _nombreController.text.trim(),
      'programa': _programaController.text.trim(),
      'documento': _documentoController.text.trim(),
      'correo': _correoController.text.trim(),
      'institucion': _institucionController.text.trim(),
      'nivel_academico': _nivelController.text.trim(),
      'semestre': _semestreController.text.trim().isEmpty
          ? null
          : int.tryParse(_semestreController.text.trim()),
      'activo': _activo,
      'usuario': _usuarioController.text.trim(),
    };

    if (!isEdit) {
      data['clave'] = _claveController.text.trim();
    }

    final ok = isEdit
        ? await provider.update(widget.initial!.idPersona, data)
        : await provider.create(data);

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la persona')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar persona' : 'Nueva persona')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _programaController,
                decoration: const InputDecoration(labelText: 'Programa'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _documentoController,
                decoration: const InputDecoration(labelText: 'Documento'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Correo invalido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _institucionController,
                decoration: const InputDecoration(labelText: 'Institucion'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nivelController,
                decoration: const InputDecoration(labelText: 'Nivel academico'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _semestreController,
                decoration: const InputDecoration(labelText: 'Semestre (opcional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _activo,
                title: const Text('Activo'),
                onChanged: (value) => setState(() => _activo = value),
              ),
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'Usuario'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              if (!isEdit) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _claveController,
                  decoration: const InputDecoration(labelText: 'Clave'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Minimo 6 caracteres' : null,
                ),
              ],
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
