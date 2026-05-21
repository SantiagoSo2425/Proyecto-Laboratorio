import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/proyecto_provider.dart';
import '../widgets/loading_view.dart';
import 'project_form_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProyectoProvider>().load();
    });
  }

  Future<void> _confirmDelete(String idProyecto) async {
    final provider = context.read<ProyectoProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text('Deseas eliminar este proyecto?'),
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
      await provider.delete(idProyecto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProyectoProvider>(
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
                  const Text('Proyectos', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const ProjectFormScreen(),
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
                  itemCount: provider.proyectos.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final proyecto = provider.proyectos[index];
                    return ListTile(
                      title: Text(proyecto.nombre),
                      subtitle: Text('${proyecto.idProyecto} - ${proyecto.entidadFinanciadora}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => ProjectFormScreen(initial: proyecto),
                              ),
                            ).then((value) {
                              if (value == true) {
                                provider.load();
                              }
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(proyecto.idProyecto),
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
