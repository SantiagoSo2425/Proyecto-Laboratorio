import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import 'personas_screen.dart';
import 'producto_list_screen.dart';
import 'project_list_screen.dart';
import 'rol_list_screen.dart';
import 'tipo_rol_list_screen.dart';
import 'work_degree_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final body = switch (_index) {
      0 => const Center(child: Text('Bienvenido')),
      1 => const PersonasScreen(),
      2 => const ProjectListScreen(),
      3 => const WorkDegreeListScreen(),
      4 => const TipoRolListScreen(),
      5 => const RolListScreen(),
      _ => const ProductoListScreen(),
    };

    return AppScaffold(
      selectedIndex: _index,
      onSelect: (value) => setState(() => _index = value),
      body: body,
    );
  }
}
