import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/persona_provider.dart';
import '../providers/rol_provider.dart';
import '../providers/trabajo_grado_provider.dart';
import '../providers/trabajo_persona_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/relation_summary.dart';
import 'trabajo_persona_form_screen.dart';

class TrabajoPersonaListScreen extends StatefulWidget {
  const TrabajoPersonaListScreen({super.key});

  @override
  State<TrabajoPersonaListScreen> createState() => _TrabajoPersonaListScreenState();
}

class _TrabajoPersonaListScreenState extends State<TrabajoPersonaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrabajoPersonaProvider>().load();
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

  Future<void> _confirmDelete(int idRelacion) async {
    final provider = context.read<TrabajoPersonaProvider>();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<TrabajoPersonaProvider>(
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

        final trabajoProvider = context.watch<TrabajoGradoProvider>();
        final personaProvider = context.watch<PersonaProvider>();
        final rolProvider = context.watch<RolProvider>();

        final trabajos = {for (final item in trabajoProvider.trabajos) item.idTrabajo: item};
        final personas = {for (final item in personaProvider.personas) item.idPersona: item};
        final roles = {for (final item in rolProvider.roles) item.idRol: item};

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trabajo-Persona', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const TrabajoPersonaFormScreen(),
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
                            title: 'Sin relaciones trabajo-persona',
                            message: 'Crea una relacion para asignar personas a trabajos.',
                            icon: Icons.link_off,
                            actionLabel: 'Crear relacion',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const TrabajoPersonaFormScreen(),
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
                          final trabajoNombre =
                              trabajos[item.idTrabajo]?.nombre ?? 'Trabajo ${item.idTrabajo}';
                          final personaNombre =
                              personas[item.idPersona]?.nombre ?? 'Persona ${item.idPersona}';
                          final rolNombre = roles[item.idRol]?.tipo ?? 'Rol ${item.idRol}';
                          return ListTile(
                            title: Text('$trabajoNombre - $personaNombre'),
                            subtitle: RelationSummary(
                              items: [
                                RelationSummaryItem(label: 'Rol', value: rolNombre),
                                RelationSummaryItem(label: 'ID', value: '${item.id}'),
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
                                          builder: (_) => TrabajoPersonaFormScreen(initial: item),
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
