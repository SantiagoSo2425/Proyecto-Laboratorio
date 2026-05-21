import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/persona_provider.dart';
import '../providers/proyecto_persona_provider.dart';
import '../providers/proyecto_provider.dart';
import '../providers/rol_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/relation_summary.dart';
import 'proyecto_persona_form_screen.dart';

class ProyectoPersonaListScreen extends StatefulWidget {
  const ProyectoPersonaListScreen({super.key});

  @override
  State<ProyectoPersonaListScreen> createState() => _ProyectoPersonaListScreenState();
}

class _ProyectoPersonaListScreenState extends State<ProyectoPersonaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProyectoPersonaProvider>().load();
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

  Future<void> _confirmDelete(int idRelacion) async {
    final provider = context.read<ProyectoPersonaProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar relacion'),
        content: const Text('Deseas eliminar esta relacion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await provider.delete(idRelacion);
    }
  }

  String _formatDate(DateTime value) => value.toIso8601String().split('T').first;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProyectoPersonaProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingView();
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.error ?? 'Error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final proyectoProvider = context.watch<ProyectoProvider>();
        final personaProvider = context.watch<PersonaProvider>();
        final rolProvider = context.watch<RolProvider>();

        final proyectos = {for (final item in proyectoProvider.proyectos) item.idProyecto: item};
        final personas = {for (final item in personaProvider.personas) item.idPersona: item};
        final roles = {for (final item in rolProvider.roles) item.idRol: item};

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Proyecto-Persona', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ProyectoPersonaFormScreen(),
                          ),
                        )
                        .then((value) {
                      if (value == true) {
                        provider.load();
                      }
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.load,
                child: provider.relaciones.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin relaciones proyecto-persona',
                            message: 'Crea una relacion para asignar personas a proyectos.',
                            icon: Icons.link_off,
                            actionLabel: 'Crear relacion',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const ProyectoPersonaFormScreen(),
                                  ),
                                )
                                .then((value) {
                              if (value == true) {
                                provider.load();
                              }
                            }),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.relaciones.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = provider.relaciones[index];
                          final fechaInicio = _formatDate(item.fechaInicio);
                          final fechaFin = item.fechaFin == null ? 'Sin fin' : _formatDate(item.fechaFin!);
                          final proyectoNombre = proyectos[item.idProyecto]?.nombre ?? item.idProyecto;
                          final personaNombre = personas[item.personaId]?.nombre ?? 'Persona ${item.personaId}';
                          final rolNombre = roles[item.idRol]?.tipo ?? 'Rol ${item.idRol}';
                          return ListTile(
                            title: Text('$proyectoNombre - $personaNombre'),
                            subtitle: RelationSummary(
                              items: [
                                RelationSummaryItem(label: 'Rol', value: rolNombre),
                                RelationSummaryItem(
                                  label: 'Horas',
                                  value: '${item.horasSemanales} h/sem',
                                ),
                                RelationSummaryItem(label: 'Inicio', value: fechaInicio),
                                RelationSummaryItem(label: 'Fin', value: fechaFin),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => ProyectoPersonaFormScreen(initial: item),
                                        ),
                                      )
                                      .then((value) {
                                    if (value == true) {
                                      provider.load();
                                    }
                                  }),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
