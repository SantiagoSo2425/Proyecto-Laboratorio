import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../providers/proyecto_persona_provider.dart';
import '../providers/proyecto_provider.dart';
import '../providers/rol_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../providers/trabajo_persona_provider.dart';
import '../widgets/section_header.dart';

class PersonaDetailScreen extends StatefulWidget {
  final Persona persona;

  const PersonaDetailScreen({super.key, required this.persona});

  @override
  State<PersonaDetailScreen> createState() => _PersonaDetailScreenState();
}

class _PersonaDetailScreenState extends State<PersonaDetailScreen> {
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
      context.read<TrabajoGradoProvider>().load(),
      context.read<RolProvider>().load(),
      context.read<ProyectoPersonaProvider>().load(),
      context.read<TrabajoPersonaProvider>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final proyectoProvider = context.watch<ProyectoProvider>();
    final trabajoProvider = context.watch<TrabajoGradoProvider>();
    final rolProvider = context.watch<RolProvider>();
    final proyectoPersonaProvider = context.watch<ProyectoPersonaProvider>();
    final trabajoPersonaProvider = context.watch<TrabajoPersonaProvider>();

    final proyectosParticipa = proyectoPersonaProvider.relaciones
        .where((item) => item.personaId == widget.persona.idPersona)
        .toList();
    final trabajosParticipa = trabajoPersonaProvider.relaciones
        .where((item) => item.idPersona == widget.persona.idPersona)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Persona ${widget.persona.idPersona}')),
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
                    Text(widget.persona.nombre, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Documento: ${widget.persona.documento}'),
                    Text('Correo: ${widget.persona.correo}'),
                    Text('Programa: ${widget.persona.programa}'),
                    Text('Institucion: ${widget.persona.institucion}'),
                    Text('Nivel academico: ${widget.persona.nivelAcademico}'),
                    Text('Semestre: ${widget.persona.semestre ?? 'N/A'}'),
                    Text('Usuario: ${widget.persona.usuario}'),
                    Text('Estado: ${widget.persona.activo ? 'Activo' : 'Inactivo'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'Proyectos en los que participa',
              subtitle: 'Incluye rol, horas y rango de fechas de participacion.',
            ),
            if (proyectoPersonaProvider.isLoading && proyectoPersonaProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (proyectosParticipa.isEmpty)
              const ListTile(
                title: Text('Sin participacion en proyectos'),
              ),
            ...proyectosParticipa.map((relacion) {
              final proyecto = proyectoProvider.proyectos
                  .where((item) => item.idProyecto == relacion.idProyecto)
                  .firstOrNull;
              final rol = rolProvider.roles.where((item) => item.idRol == relacion.idRol).firstOrNull;
              final inicio = relacion.fechaInicio.toIso8601String().split('T').first;
              final fin = relacion.fechaFin == null
                  ? 'Sin fecha fin'
                  : relacion.fechaFin!.toIso8601String().split('T').first;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${proyecto?.idProyecto ?? relacion.idProyecto} - ${proyecto?.nombre ?? 'Proyecto'}'),
                  subtitle: Text(
                    'Rol: ${rol?.tipo ?? relacion.idRol} | Horas: ${relacion.horasSemanales}\n'
                    'Inicio: $inicio | Fin: $fin',
                  ),
                  isThreeLine: true,
                ),
              );
            }),
            const SizedBox(height: 12),
            const SectionHeader(
              title: 'Trabajos de grado en los que participa',
              subtitle: 'Incluye el rol que cumple en cada trabajo.',
            ),
            if (trabajoPersonaProvider.isLoading && trabajoPersonaProvider.relaciones.isEmpty)
              const LinearProgressIndicator(),
            if (trabajosParticipa.isEmpty)
              const ListTile(
                title: Text('Sin participacion en trabajos de grado'),
              ),
            ...trabajosParticipa.map((relacion) {
              final trabajo =
                  trabajoProvider.trabajos.where((item) => item.idTrabajo == relacion.idTrabajo).firstOrNull;
              final rol = rolProvider.roles.where((item) => item.idRol == relacion.idRol).firstOrNull;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${trabajo?.idTrabajo ?? relacion.idTrabajo} - ${trabajo?.nombre ?? 'Trabajo'}'),
                  subtitle: Text('Rol: ${rol?.tipo ?? relacion.idRol}'),
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