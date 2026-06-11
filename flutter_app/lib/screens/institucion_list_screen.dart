import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/institucion_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import 'institucion_form_screen.dart';

class InstitucionListScreen extends StatefulWidget {
  const InstitucionListScreen({super.key});

  @override
  State<InstitucionListScreen> createState() => _InstitucionListScreenState();
}

class _InstitucionListScreenState extends State<InstitucionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstitucionProvider>().load();
    });
  }

  Future<void> _confirmDelete(int idInstitucion) async {
    final provider = context.read<InstitucionProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar institucion'),
        content: const Text('Deseas eliminar esta institucion?'),
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
      await provider.delete(idInstitucion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstitucionProvider>(
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
                  const Text('Instituciones', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const InstitucionFormScreen(),
                          ),
                        )
                        .then((value) {
                      if (value == true) {
                        provider.load();
                      }
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.load,
                child: provider.instituciones.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin instituciones',
                            message: 'Crea instituciones para asociarlas a personas y proyectos.',
                            icon: Icons.apartment_outlined,
                            actionLabel: 'Crear institucion',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const InstitucionFormScreen(),
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
                        itemCount: provider.instituciones.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = provider.instituciones[index];
                          return ListTile(
                            title: Text(item.nombre),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => InstitucionFormScreen(initial: item),
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
                                  onPressed: () => _confirmDelete(item.idInstitucion),
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
