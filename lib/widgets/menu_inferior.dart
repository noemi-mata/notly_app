import 'package:flutter/material.dart';

import '../data/clases_repo.dart';
import '../tema/app_theme.dart';

enum Seccion { clases, favoritos, descargas, administrar, perfil }

extension SeccionX on Seccion {
  String get etiqueta => switch (this) {
        Seccion.clases => 'Clases',
        Seccion.favoritos => 'Favoritos',
        Seccion.descargas => 'Descargas',
        Seccion.administrar => 'Administrar',
        Seccion.perfil => 'Perfil',
      };

  IconData get icono => switch (this) {
        Seccion.clases => Icons.menu_book_outlined,
        Seccion.favoritos => Icons.star_border,
        Seccion.descargas => Icons.file_download_outlined,
        Seccion.administrar => Icons.verified_user_outlined,
        Seccion.perfil => Icons.person_outline,
      };
}

class MenuInferior extends StatelessWidget {
  const MenuInferior({super.key, this.actual = Seccion.clases});

  final Seccion actual;

  void _abrir(BuildContext context, Seccion seccion) {
    if (seccion == Seccion.clases) {
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
      return;
    }
    // TODO: pantallas pendientes (favoritos, descargas, administrar, perfil).
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${seccion.etiqueta}: pantalla pendiente')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ClasesRepo.instance,
      builder: (context, _) {
        final secciones = Seccion.values
            .where((s) =>
                s != Seccion.administrar || ClasesRepo.instance.esAdminDeAlguna)
            .toList();

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColores.bordeTarjeta, width: 1.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                for (final s in secciones)
                  Expanded(
                    child: _ItemMenu(
                      seccion: s,
                      activo: s == actual,
                      onTap: () => _abrir(context, s),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({
    required this.seccion,
    required this.activo,
    required this.onTap,
  });

  final Seccion seccion;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppColores.primario : AppColores.textoSuave;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: activo ? AppColores.primario : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(seccion.icono, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              seccion.etiqueta,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
