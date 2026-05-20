import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import 'personas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final body = _index == 0
        ? const Center(child: Text('Bienvenido'))
        : const PersonasScreen();

    return AppScaffold(
      selectedIndex: _index,
      onSelect: (value) => setState(() => _index = value),
      body: body,
    );
  }
}
