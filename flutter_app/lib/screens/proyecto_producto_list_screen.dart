import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/producto_provider.dart';
import '../providers/proyecto_producto_provider.dart';
import '../providers/proyecto_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/relation_summary.dart';
import 'proyecto_producto_form_screen.dart';

class ProyectoProductoListScreen extends StatefulWidget {
  const ProyectoProductoListScreen({super.key});

  @override
  State<ProyectoProductoListScreen> createState() => _ProyectoProductoListScreenState();
}

class _ProyectoProductoListScreenState extends State<ProyectoProductoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProyectoProductoProvider>().load();
      final proyectoProvider = context.read<ProyectoProvider>();
      if (proyectoProvider.proyectos.isEmpty) {
        proyectoProvider.load();
      }
      final productoProvider = context.read<ProductoProvider>();
      if (productoProvider.productos.isEmpty) {
        productoProvider.load();
      }
    });
  }

  Future<void> _confirmDelete(int idRelacion) async {
    final provider = context.read<ProyectoProductoProvider>();
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
    return Consumer<ProyectoProductoProvider>(
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
        final productoProvider = context.watch<ProductoProvider>();

        final proyectos = {for (final item in proyectoProvider.proyectos) item.idProyecto: item};
        final productos = {for (final item in productoProvider.productos) item.idProducto: item};

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Proyecto-Producto', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const ProyectoProductoFormScreen(),
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
                            title: 'Sin relaciones proyecto-producto',
                            message: 'Vincula productos a proyectos para continuar.',
                            icon: Icons.link_off,
                            actionLabel: 'Crear relacion',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const ProyectoProductoFormScreen(),
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
                          final proyectoNombre = proyectos[item.idProyecto]?.nombre ?? item.idProyecto;
                          final productoNombre =
                              productos[item.idProducto]?.descripcion ?? 'Producto ${item.idProducto}';
                          return ListTile(
                            title: Text('$proyectoNombre - $productoNombre'),
                            subtitle: RelationSummary(
                              items: [
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
                                          builder: (_) => ProyectoProductoFormScreen(initial: item),
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
