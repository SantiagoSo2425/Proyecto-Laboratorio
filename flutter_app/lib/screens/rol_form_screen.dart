import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/rol.dart';
import '../providers/rol_provider.dart';
import '../providers/tipo_rol_provider.dart';
import '../widgets/loading_view.dart';

class RolFormScreen extends StatefulWidget {
  final Rol? initial;

  const RolFormScreen({super.key, this.initial});

  @override
  State<RolFormScreen> createState() => _RolFormScreenState();
}

class _RolFormScreenState extends State<RolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  String? _selectedTipoId;
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedTipoId = initial.idTipo.toString();
      _nombreController.text = initial.tipo;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tipoProvider = context.read<TipoRolProvider>();
      if (tipoProvider.tipos.isEmpty) {
        tipoProvider.load();
      }
    });
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<RolProvider>();
    final tipoId = int.parse(_selectedTipoId!);
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            idRol: widget.initial!.idRol,
            idTipo: tipoId,
            tipo: _nombreController.text.trim(),
          )
        : await provider.create(
            idTipo: tipoId,
            tipo: _nombreController.text.trim(),
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el rol')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final tipoProvider = context.watch<TipoRolProvider>();
    final tipos = tipoProvider.tipos;
    final hasSelected = _selectedTipoId != null &&
        tipos.any((item) => item.idTipo.toString() == _selectedTipoId);
    final currentValue = hasSelected ? _selectedTipoId : null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar rol' : 'Nuevo rol')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (tipoProvider.isLoading && tipos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: currentValue,
                decoration: const InputDecoration(labelText: 'Tipo de rol'),
                items: tipos
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.idTipo.toString(),
                        child: Text(item.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTipoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!tipoProvider.isLoading && tipos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay tipos de rol disponibles. Crea uno primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedTipoId == null ? null : _submit,
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
