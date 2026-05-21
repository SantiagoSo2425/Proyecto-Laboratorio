import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/proyecto_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import 'project_detail_screen.dart';
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

  Future<void> _openForm() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const ProjectFormScreen(),
      ),
    );

    if (result == true) {
      await context.read<ProyectoProvider>().load();
    }
  }

  Future<void> _openEditForm(String idProyecto) async {
    final provider = context.read<ProyectoProvider>();
    final proyecto = provider.proyectos.firstWhere((item) => item.idProyecto == idProyecto);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(initial: proyecto),
      ),
    );

    if (result == true) {
      await provider.load();
    }
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

  Future<void> _openDetail(String idProyecto) async {
    final provider = context.read<ProyectoProvider>();
    final proyecto = provider.proyectos.firstWhere((item) => item.idProyecto == idProyecto);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(proyecto: proyecto),
      ),
    );
    if (!mounted) {
      return;
    }
    await provider.load();
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
                    onPressed: _openForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.load,
                child: provider.proyectos.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin proyectos',
                            message: 'Crea un proyecto para empezar a relacionar datos.',
                            icon: Icons.folder_open,
                            actionLabel: 'Crear proyecto',
                            onAction: _openForm,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.proyectos.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final proyecto = provider.proyectos[index];
                          return ListTile(
                            onTap: () => _openDetail(proyecto.idProyecto),
                            title: Text(proyecto.nombre),
                            subtitle: Text('${proyecto.idProyecto} - ${proyecto.entidadFinanciadora}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () => _openDetail(proyecto.idProyecto),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openEditForm(proyecto.idProyecto),
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
