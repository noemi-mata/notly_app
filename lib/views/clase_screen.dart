import 'package:flutter/material.dart';

import '../data/clases_repo.dart';
import '../modelos/clase.dart';
import '../tema/app_theme.dart';
import '../widgets/encabezado.dart';
import '../widgets/menu_inferior.dart';
import '../widgets/tarjeta_apunte.dart';

class ClaseScreen extends StatelessWidget {
  const ClaseScreen({super.key, required this.clase});

  final Clase clase;

  @override
  Widget build(BuildContext context) {
    final apuntes = ClasesRepo.instance.apuntesDe(clase.id);

    return Scaffold(
      bottomNavigationBar: const MenuInferior(actual: Seccion.clases),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Encabezado(titulo: clase.nombre),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Text(
                clase.detalle,
                style: const TextStyle(color: AppColores.textoSuave),
              ),
            ),
            const SizedBox(height: 20),
            if (apuntes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Aún no hay apuntes en esta clase',
                    style: TextStyle(color: AppColores.textoSuave),
                  ),
                ),
              ),
            for (final apunte in apuntes) ...[
              TarjetaApunte(
                apunte: apunte,
                onDescargar: () {
                  // TODO: descarga real del archivo.
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text('Descargando "${apunte.tema}"…')),
                    );
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
