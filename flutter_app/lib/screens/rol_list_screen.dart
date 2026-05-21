import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rol_provider.dart';
import '../providers/tipo_rol_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import 'rol_form_screen.dart';

class RolListScreen extends StatefulWidget {
  const RolListScreen({super.key});

  @override
  State<RolListScreen> createState() => _RolListScreenState();
}

class _RolListScreenState extends State<RolListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolProvider>().load();
      final tipoProvider = context.read<TipoRolProvider>();
      if (tipoProvider.tipos.isEmpty) {
        tipoProvider.load();
      }
    });
  }

  Future<void> _confirmDelete(int idRol) async {
    final provider = context.read<RolProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: const Text('Deseas eliminar este rol?'),
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
      await provider.delete(idRol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RolProvider>(
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

        final tipoProvider = context.watch<TipoRolProvider>();
        final tipos = {for (final item in tipoProvider.tipos) item.idTipo: item};

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Roles', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const RolFormScreen(),
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
                child: provider.roles.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin roles',
                            message: 'Crea roles para asignar personas en proyectos y trabajos.',
                            icon: Icons.badge_outlined,
                            actionLabel: 'Crear rol',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const RolFormScreen(),
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
                        itemCount: provider.roles.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = provider.roles[index];
                          final tipoNombre = tipos[item.idTipo]?.nombre ?? 'Tipo ${item.idTipo}';
                          return ListTile(
                            title: Text(item.tipo),
                            subtitle: Text(tipoNombre),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => RolFormScreen(initial: item),
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
                                  onPressed: () => _confirmDelete(item.idRol),
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
