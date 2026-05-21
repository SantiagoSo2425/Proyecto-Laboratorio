import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trabajo_grado_provider.dart';
import '../widgets/loading_view.dart';
import 'work_degree_form_screen.dart';

class WorkDegreeListScreen extends StatefulWidget {
  const WorkDegreeListScreen({super.key});

  @override
  State<WorkDegreeListScreen> createState() => _WorkDegreeListScreenState();
}

class _WorkDegreeListScreenState extends State<WorkDegreeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrabajoGradoProvider>().load();
    });
  }

  Future<void> _confirmDelete(int idTrabajo) async {
    final provider = context.read<TrabajoGradoProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar trabajo de grado'),
        content: const Text('Deseas eliminar este trabajo?'),
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
      await provider.delete(idTrabajo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrabajoGradoProvider>(
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
                  const Text('Trabajos de grado', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const WorkDegreeFormScreen(),
                      ),
                    ).then((value) {
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.trabajos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final trabajo = provider.trabajos[index];
                    return ListTile(
                      title: Text(trabajo.nombre),
                      subtitle: Text('${trabajo.idProyecto} - ${trabajo.facultad}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => WorkDegreeFormScreen(initial: trabajo),
                              ),
                            ).then((value) {
                              if (value == true) {
                                provider.load();
                              }
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(trabajo.idTrabajo),
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
