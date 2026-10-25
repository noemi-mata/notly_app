import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxFlutterInitialize;

import 'data/app_store.dart';
import 'views/login_view.dart';
import 'views/shell_view.dart';
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
      home: ListenableBuilder(
        listenable: AppStore.instance,
        builder: (context, _) => AppStore.instance.usuarioActual == null
            ? const LoginView()
            : const ShellView(),
      ),
    );
  }
}
