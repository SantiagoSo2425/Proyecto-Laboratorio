import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/persona.dart';
import '../providers/persona_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_view.dart';
import 'persona_detail_screen.dart';
import 'persona_form_screen.dart';
import 'persona_password_screen.dart';

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonaProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonaProvider>(
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
                  const Text('Personas', style: TextStyle(fontSize: 18)),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const PersonaFormScreen(),
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
                child: provider.personas.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          EmptyStateView(
                            title: 'Sin personas',
                            message: 'Crea personas para asignarlas a proyectos y trabajos.',
                            icon: Icons.people_outline,
                            actionLabel: 'Crear persona',
                            onAction: () => Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => const PersonaFormScreen(),
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
                        itemCount: provider.personas.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final persona = provider.personas[index];
                          return _PersonaTile(
                            persona: persona,
                            onRefresh: provider.load,
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

class _PersonaTile extends StatelessWidget {
  final Persona persona;
  final Future<void> Function() onRefresh;

  const _PersonaTile({required this.persona, required this.onRefresh});

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<PersonaProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: const Text('Deseas eliminar esta persona?'),
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
      await provider.delete(persona.idPersona);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => PersonaDetailScreen(persona: persona),
        ),
      ),
      title: Text(persona.nombre),
      subtitle: Text('${persona.programa} - ${persona.correo}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => PersonaDetailScreen(persona: persona),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => Navigator.of(context)
                .push<bool>(
                  MaterialPageRoute(
                    builder: (_) => PersonaPasswordScreen(idPersona: persona.idPersona),
                  ),
                )
                .then((value) {
              if (value == true) {
                onRefresh();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context)
                .push<bool>(
                  MaterialPageRoute(
                    builder: (_) => PersonaFormScreen(initial: persona),
                  ),
                )
                .then((value) {
              if (value == true) {
                onRefresh();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}
