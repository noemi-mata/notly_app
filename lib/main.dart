import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxFlutterInitialize;

import 'data/app_store.dart';
import 'views/login_view.dart';
import 'views/shell_view.dart';
import 'views/splash_view.dart';
import 'widgets/app_tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  try {
    await AppStore.instance.cargar();
  } catch (_) {}
  runApp(const NotlyApp());
}

class NotlyApp extends StatelessWidget {
  const NotlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notly',
      debugShowCheckedModeBanner: false,
      theme: AppTema.claro,
      // Si hay sesión muestra la app; si no, el inicio de sesión.
      home: const _Raiz(),
    );
  }
}

/// Muestra la pantalla de bienvenida un par de segundos y después la app.
class _Raiz extends StatefulWidget {
  const _Raiz();

  @override
  State<_Raiz> createState() => _RaizState();
}

class _RaizState extends State<_Raiz> {
  bool _splash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _splash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_splash) return const SplashView();
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) => AppStore.instance.usuarioActual == null
          ? const LoginView()
          : const ShellView(),
    );
  }
}
