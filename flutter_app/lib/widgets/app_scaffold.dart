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
            ListTile(
              selected: selectedIndex == 2,
              leading: const Icon(Icons.folder),
              title: const Text('Proyectos'),
              onTap: () {
                Navigator.pop(context);
                onSelect(2);
              },
            ),
            ListTile(
              selected: selectedIndex == 3,
              leading: const Icon(Icons.school),
              title: const Text('Trabajos de grado'),
              onTap: () {
                Navigator.pop(context);
                onSelect(3);
              },
            ),
            const Divider(),
            ListTile(
              selected: selectedIndex == 4,
              leading: const Icon(Icons.category),
              title: const Text('Tipos de rol'),
              onTap: () {
                Navigator.pop(context);
                onSelect(4);
              },
            ),
            ListTile(
              selected: selectedIndex == 5,
              leading: const Icon(Icons.badge),
              title: const Text('Roles'),
              onTap: () {
                Navigator.pop(context);
                onSelect(5);
              },
            ),
            ListTile(
              selected: selectedIndex == 6,
              leading: const Icon(Icons.inventory_2),
              title: const Text('Productos'),
              onTap: () {
                Navigator.pop(context);
                onSelect(6);
              },
            ),
            ListTile(
              selected: selectedIndex == 7,
              leading: const Icon(Icons.description),
              title: const Text('Generador README'),
              onTap: () {
                Navigator.pop(context);
                onSelect(7);
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
