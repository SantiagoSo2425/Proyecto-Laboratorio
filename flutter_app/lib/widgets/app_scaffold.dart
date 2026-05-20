import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto Laboratorio')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              selected: selectedIndex == 0,
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                onSelect(0);
              },
            ),
            ListTile(
              selected: selectedIndex == 1,
              leading: const Icon(Icons.people),
              title: const Text('Personas'),
              onTap: () {
                Navigator.pop(context);
                onSelect(1);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Salir'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
