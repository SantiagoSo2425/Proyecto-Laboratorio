import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/persona_provider.dart';
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
