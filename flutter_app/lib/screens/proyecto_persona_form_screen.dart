import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proyecto_persona.dart';
import '../providers/persona_provider.dart';
import '../providers/proyecto_persona_provider.dart';
import '../providers/proyecto_provider.dart';
import '../providers/rol_provider.dart';
import '../widgets/loading_view.dart';

class ProyectoPersonaFormScreen extends StatefulWidget {
  final ProyectoPersona? initial;

  const ProyectoPersonaFormScreen({super.key, this.initial});

  @override
  State<ProyectoPersonaFormScreen> createState() => _ProyectoPersonaFormScreenState();
}

class _ProyectoPersonaFormScreenState extends State<ProyectoPersonaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _horasController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  String? _selectedProyectoId;
  String? _selectedPersonaId;
  String? _selectedRolId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedProyectoId = initial.idProyecto;
      _selectedPersonaId = initial.personaId.toString();
      _selectedRolId = initial.idRol.toString();
      _horasController.text = initial.horasSemanales.toString();
      _fechaInicio = initial.fechaInicio;
      _fechaInicioController.text = _formatDate(initial.fechaInicio);
      if (initial.fechaFin != null) {
        _fechaFin = initial.fechaFin;
        _fechaFinController.text = _formatDate(initial.fechaFin!);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final proyectoProvider = context.read<ProyectoProvider>();
      if (proyectoProvider.proyectos.isEmpty) {
        proyectoProvider.load();
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

  @override
  void dispose() {
    _horasController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime value) => value.toIso8601String().split('T').first;

  Future<void> _pickFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        _fechaInicioController.text = _formatDate(picked);
        if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
          _fechaFin = null;
          _fechaFinController.text = '';
        }
      });
    }
  }

  Future<void> _pickFechaFin() async {
    final base = _fechaFin ?? _fechaInicio ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fechaFin = picked;
        _fechaFinController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final proyectoId = _selectedProyectoId;
    final personaId = _selectedPersonaId;
    final rolId = _selectedRolId;

    if (proyectoId == null || personaId == null || rolId == null || _fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final horas = int.tryParse(_horasController.text.trim());
    if (horas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horas semanales invalidas')),
      );
      return;
    }

    final provider = context.read<ProyectoPersonaProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            id: widget.initial!.id,
            idProyecto: proyectoId,
            personaId: int.parse(personaId),
            idRol: int.parse(rolId),
            horasSemanales: horas,
            fechaInicio: _fechaInicio!,
            fechaFin: _fechaFin,
          )
        : await provider.create(
            idProyecto: proyectoId,
            personaId: int.parse(personaId),
            idRol: int.parse(rolId),
            horasSemanales: horas,
            fechaInicio: _fechaInicio!,
            fechaFin: _fechaFin,
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
    final proyectoProvider = context.watch<ProyectoProvider>();
    final personaProvider = context.watch<PersonaProvider>();
    final rolProvider = context.watch<RolProvider>();

    final proyectos = proyectoProvider.proyectos;
    final personas = personaProvider.personas;
    final roles = rolProvider.roles;

    final hasProyecto = _selectedProyectoId != null &&
        proyectos.any((p) => p.idProyecto == _selectedProyectoId);
    final hasPersona = _selectedPersonaId != null &&
        personas.any((p) => p.idPersona.toString() == _selectedPersonaId);
    final hasRol = _selectedRolId != null &&
        roles.any((r) => r.idRol.toString() == _selectedRolId);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar relacion' : 'Nueva relacion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (proyectoProvider.isLoading && proyectos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LoadingView(),
                ),
              DropdownButtonFormField<String>(
                value: hasProyecto ? _selectedProyectoId : null,
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
              TextFormField(
                controller: _horasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Horas semanales'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Numero invalido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fechaInicioController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha inicio',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickFechaInicio,
                validator: (_) => _fechaInicio == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fechaFinController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha fin (opcional)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickFechaFin,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _fechaFin = null;
                    _fechaFinController.text = '';
                  });
                },
                child: const Text('Limpiar fecha fin'),
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
