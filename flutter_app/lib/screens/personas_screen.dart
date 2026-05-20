import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/persona_provider.dart';
import '../widgets/loading_view.dart';

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

        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.personas.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final persona = provider.personas[index];
              return ListTile(
                title: Text(persona.nombre),
                subtitle: Text('${persona.programa} - ${persona.correo}'),
                trailing: Text(persona.usuario),
              );
            },
          ),
        );
      },
    );
  }
}
