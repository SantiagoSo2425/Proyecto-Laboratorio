import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/institucion.dart';
import '../providers/institucion_provider.dart';

class InstitucionFormScreen extends StatefulWidget {
  final Institucion? initial;

  const InstitucionFormScreen({super.key, this.initial});

  @override
  State<InstitucionFormScreen> createState() => _InstitucionFormScreenState();
}

class _InstitucionFormScreenState extends State<InstitucionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nombreController.text = initial.nombre;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<InstitucionProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(widget.initial!.idInstitucion, _nombreController.text.trim())
        : await provider.create(_nombreController.text.trim());

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la institucion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar institucion' : 'Nueva institucion')),
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
