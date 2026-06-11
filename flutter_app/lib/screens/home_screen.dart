import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import 'contrato_list_screen.dart';
import 'institucion_list_screen.dart';
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
      4 => const InstitucionListScreen(),
      5 => const ContratoListScreen(),
      6 => const TipoRolListScreen(),
      7 => const RolListScreen(),
      8 => const ProductoListScreen(),
      _ => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'El generador README se abre desde el detalle de un proyecto.\nSelecciona un proyecto para continuar.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
    };

    return AppScaffold(
      selectedIndex: _index,
      onSelect: (value) => setState(() => _index = value),
      body: body,
    );
  }
}
