import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contrato_provider.dart';
import '../providers/persona_provider.dart';
import '../providers/proyecto_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import 'contrato_form_screen.dart';

class ContratoListScreen extends StatefulWidget {
  const ContratoListScreen({super.key});

  @override
  State<ContratoListScreen> createState() => _ContratoListScreenState();
}

class _ContratoListScreenState extends State<ContratoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContratoProvider>().load();
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

  Future<void> _confirmDelete(int id) async {
    final provider = context.read<ContratoProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contrato'),
        content: const Text('Deseas eliminar este contrato?'),
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
      await provider.delete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContratoProvider>(
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Contratos', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ContratoFormScreen(),
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
                child: provider.contratos.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin contratos',
                            message: 'Crea contratos para vincular personas con proyectos.',
                            icon: Icons.description_outlined,
                            actionLabel: 'Crear contrato',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const ContratoFormScreen(),
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
                        itemCount: provider.contratos.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = provider.contratos[index];
                          return ListTile(
                            title: Text(item.personaNombre ?? 'Persona ${item.idPersona}'),
                            subtitle: Text('${item.proyectoNombre ?? item.idProyecto} | Proyecto ${item.idProyecto}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => ContratoFormScreen(initial: item),
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
