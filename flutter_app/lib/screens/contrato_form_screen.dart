import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contrato.dart';
import '../providers/contrato_provider.dart';
import '../providers/persona_provider.dart';
import '../providers/proyecto_provider.dart';
import '../widgets/loading_view.dart';

class ContratoFormScreen extends StatefulWidget {
  final Contrato? initial;

  const ContratoFormScreen({super.key, this.initial});

  @override
  State<ContratoFormScreen> createState() => _ContratoFormScreenState();
}

class _ContratoFormScreenState extends State<ContratoFormScreen> {
  String? _selectedProyectoId;
  int? _selectedPersonaId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedProyectoId = initial.idProyecto;
      _selectedPersonaId = initial.idPersona;
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
    });
  }

  Future<void> _submit() async {
    if (_selectedProyectoId == null || _selectedPersonaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    final provider = context.read<ContratoProvider>();
    final isEdit = widget.initial != null;
    final ok = isEdit
        ? await provider.update(
            id: widget.initial!.id,
            idProyecto: _selectedProyectoId!,
            idPersona: _selectedPersonaId!,
          )
        : await provider.create(
            idProyecto: _selectedProyectoId!,
            idPersona: _selectedPersonaId!,
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el contrato')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final proyectoProvider = context.watch<ProyectoProvider>();
    final personaProvider = context.watch<PersonaProvider>();

    final proyectos = proyectoProvider.proyectos;
    final personas = personaProvider.personas;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar contrato' : 'Nuevo contrato')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (proyectoProvider.isLoading && proyectos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LoadingView(),
              ),
            DropdownButtonFormField<String>(
              value: _selectedProyectoId,
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
            DropdownButtonFormField<int>(
              value: _selectedPersonaId,
              decoration: const InputDecoration(labelText: 'Persona'),
              items: personas
                  .map(
                    (persona) => DropdownMenuItem(
                      value: persona.idPersona,
                      child: Text('${persona.nombre} - ${persona.documento}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedPersonaId = value),
            ),
            if (!personaProvider.isLoading && personas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No hay personas disponibles. Crea una persona primero.',
                  style: TextStyle(color: Colors.redAccent),
                ),
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
    );
  }
}
