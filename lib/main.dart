import 'package:flutter/material.dart';

import 'views/inicio_screen.dart';
import 'tema/app_theme.dart';

void main() => runApp(const ApuntesCompartidosApp());

class ApuntesCompartidosApp extends StatelessWidget {
  const ApuntesCompartidosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apuntes Compartidos',
      debugShowCheckedModeBanner: false,
      theme: AppTema.claro,
      home: const InicioScreen(),
    );
  }
}
