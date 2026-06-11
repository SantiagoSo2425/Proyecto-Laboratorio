import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/contrato_provider.dart';
import 'providers/institucion_provider.dart';
import 'providers/persona_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/producto_trabajo_provider.dart';
import 'providers/proyecto_persona_provider.dart';
import 'providers/proyecto_producto_provider.dart';
import 'providers/proyecto_provider.dart';
import 'providers/rol_provider.dart';
import 'providers/tipo_rol_provider.dart';
import 'providers/trabajo_grado_provider.dart';
import 'providers/trabajo_persona_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadToken();
  runApp(App(authProvider: authProvider));
}

class App extends StatelessWidget {
  final AuthProvider authProvider;

  const App({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, PersonaProvider>(
          create: (_) => PersonaProvider(),
          update: (_, auth, provider) {
            provider ??= PersonaProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TipoRolProvider>(
          create: (_) => TipoRolProvider(),
          update: (_, auth, provider) {
            provider ??= TipoRolProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RolProvider>(
          create: (_) => RolProvider(),
          update: (_, auth, provider) {
            provider ??= RolProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductoProvider>(
          create: (_) => ProductoProvider(),
          update: (_, auth, provider) {
            provider ??= ProductoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProyectoProvider>(
          create: (_) => ProyectoProvider(),
          update: (_, auth, provider) {
            provider ??= ProyectoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrabajoGradoProvider>(
          create: (_) => TrabajoGradoProvider(),
          update: (_, auth, provider) {
            provider ??= TrabajoGradoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProyectoPersonaProvider>(
          create: (_) => ProyectoPersonaProvider(),
          update: (_, auth, provider) {
            provider ??= ProyectoPersonaProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrabajoPersonaProvider>(
          create: (_) => TrabajoPersonaProvider(),
          update: (_, auth, provider) {
            provider ??= TrabajoPersonaProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProyectoProductoProvider>(
          create: (_) => ProyectoProductoProvider(),
          update: (_, auth, provider) {
            provider ??= ProyectoProductoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductoTrabajoProvider>(
          create: (_) => ProductoTrabajoProvider(),
          update: (_, auth, provider) {
            provider ??= ProductoTrabajoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ContratoProvider>(
          create: (_) => ContratoProvider(),
          update: (_, auth, provider) {
            provider ??= ContratoProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, InstitucionProvider>(
          create: (_) => InstitucionProvider(),
          update: (_, auth, provider) {
            provider ??= InstitucionProvider();
            provider.attachAuth(auth);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Proyecto Laboratorio',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
