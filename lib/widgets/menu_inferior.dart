import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/usuario.dart';
import 'app_tema.dart';

enum Seccion { clases, favoritos, descargas, administrar, perfil }

/// Sección activa (compartida por todas las pantallas).
final ValueNotifier<Seccion> seccionActual = ValueNotifier(Seccion.clases);

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

/// Menú inferior del usuario. "Administrar" solo aparece en modo administrador.
class MenuInferior extends StatelessWidget {
  const MenuInferior({super.key, this.activa});

  /// Si es null usa la sección global.
  final Seccion? activa;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppStore.instance, seccionActual]),
      builder: (context, _) {
        final secciones = Seccion.values
            .where((s) =>
                s != Seccion.administrar || AppStore.instance.mostrarAdministrar)
            .toList();
        final actual = activa ?? seccionActual.value;

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
                      onTap: () {
                        seccionActual.value = s;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
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

/// Menú secundario de la esquina: cambia el rol con el que usas la app
/// (alumno, docente o administrador).
class MenuEsquina extends StatelessWidget {
  const MenuEsquina({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        // Las cuentas de administrador solo tienen un rol: no hay nada que cambiar.
        if (store.modosDisponibles.length < 2) return const SizedBox.shrink();

        return PopupMenuButton<ModoUsuario>(
          tooltip: 'Cambiar de rol',
          icon: const Icon(Icons.manage_accounts_outlined, color: AppColores.texto),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (nuevo) {
            final nav = Navigator.of(context);
            store.cambiarModo(nuevo);
            if (!store.mostrarAdministrar &&
                seccionActual.value == Seccion.administrar) {
              seccionActual.value = Seccion.clases;
            }
            nav.popUntil((r) => r.isFirst);
          },
          itemBuilder: (_) => [
            const PopupMenuItem<ModoUsuario>(
              enabled: false,
              child: Text('Usar la app como…',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColores.primario)),
            ),
            const PopupMenuDivider(),
            for (final m in store.modosDisponibles)
              PopupMenuItem<ModoUsuario>(
                value: m,
                child: Row(
                  children: [
                    Icon(
                      m == store.modo
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: m == store.modo
                          ? AppColores.primario
                          : AppColores.textoSuave,
                    ),
                    const SizedBox(width: 12),
                    Text(m.etiqueta,
                        style: TextStyle(
                            fontWeight: m == store.modo
                                ? FontWeight.w800
                                : FontWeight.w600)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
