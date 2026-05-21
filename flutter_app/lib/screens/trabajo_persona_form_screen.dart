import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trabajo_persona.dart';
import '../providers/persona_provider.dart';
import '../providers/rol_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../providers/trabajo_persona_provider.dart';
import '../widgets/loading_view.dart';

class TrabajoPersonaFormScreen extends StatefulWidget {
  final TrabajoPersona? initial;

  const TrabajoPersonaFormScreen({super.key, this.initial});

  @override
  State<TrabajoPersonaFormScreen> createState() => _TrabajoPersonaFormScreenState();
}

class _TrabajoPersonaFormScreenState extends State<TrabajoPersonaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTrabajoId;
  String? _selectedPersonaId;
  String? _selectedRolId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedTrabajoId = initial.idTrabajo.toString();
      _selectedPersonaId = initial.idPersona.toString();
      _selectedRolId = initial.idRol.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trabajoProvider = context.read<TrabajoGradoProvider>();
      if (trabajoProvider.trabajos.isEmpty) {
        trabajoProvider.load();
      }
      final personaProvider = context.read<PersonaProvider>();
      if (personaProvider.personas.isEmpty) {
        personaProvider.load();
      }
      final rolProvider = context.read<RolProvider>();
      if (rolProvider.roles.isEmpty) {
        rolProvider.load();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final trabajoId = _selectedTrabajoId;
    final personaId = _selectedPersonaId;
    final rolId = _selectedRolId;

    if (trabajoId == null || personaId == null || rolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final provider = context.read<TrabajoPersonaProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            id: widget.initial!.id,
            idTrabajo: int.parse(trabajoId),
            idPersona: int.parse(personaId),
            idRol: int.parse(rolId),
          )
        : await provider.create(
            idTrabajo: int.parse(trabajoId),
            idPersona: int.parse(personaId),
            idRol: int.parse(rolId),
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la relacion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final trabajoProvider = context.watch<TrabajoGradoProvider>();
    final personaProvider = context.watch<PersonaProvider>();
    final rolProvider = context.watch<RolProvider>();

    final trabajos = trabajoProvider.trabajos;
    final personas = personaProvider.personas;
    final roles = rolProvider.roles;

    final hasTrabajo = _selectedTrabajoId != null &&
        trabajos.any((t) => t.idTrabajo.toString() == _selectedTrabajoId);
    final hasPersona = _selectedPersonaId != null &&
        personas.any((p) => p.idPersona.toString() == _selectedPersonaId);
    final hasRol = _selectedRolId != null && roles.any((r) => r.idRol.toString() == _selectedRolId);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar relacion' : 'Nueva relacion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (trabajoProvider.isLoading && trabajos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasTrabajo ? _selectedTrabajoId : null,
                decoration: const InputDecoration(labelText: 'Trabajo de grado'),
                items: trabajos
                    .map(
                      (trabajo) => DropdownMenuItem(
                        value: trabajo.idTrabajo.toString(),
                        child: Text('${trabajo.idTrabajo} - ${trabajo.nombre}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedTrabajoId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!trabajoProvider.isLoading && trabajos.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay trabajos disponibles. Crea un trabajo primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              if (personaProvider.isLoading && personas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasPersona ? _selectedPersonaId : null,
                decoration: const InputDecoration(labelText: 'Persona'),
                items: personas
                    .map(
                      (persona) => DropdownMenuItem(
                        value: persona.idPersona.toString(),
                        child: Text('${persona.nombre} - ${persona.documento}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedPersonaId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!personaProvider.isLoading && personas.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay personas disponibles. Crea una persona primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
              if (rolProvider.isLoading && roles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasRol ? _selectedRolId : null,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: roles
                    .map(
                      (rol) => DropdownMenuItem(
                        value: rol.idRol.toString(),
                        child: Text(rol.tipo),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedRolId = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              if (!rolProvider.isLoading && roles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay roles disponibles. Crea un rol primero.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 12),
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
