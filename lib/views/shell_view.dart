import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/menu_inferior.dart';
import 'admin_panel_tab.dart';
import 'descargas_tab.dart';
import 'favoritos_tab.dart';
import 'inicio_tab.dart';
import 'perfil_tab.dart';

/// Pantalla base con el menú inferior. Cada pestaña es un widget.
class ShellView extends StatefulWidget {
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  @override
  void initState() {
    super.initState();
    seccionActual.value = Seccion.clases;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([seccionActual, AppStore.instance]),
      builder: (context, _) {
        var seccion = seccionActual.value;
        if (seccion == Seccion.administrar &&
            !AppStore.instance.mostrarAdministrar) {
          seccion = Seccion.clases;
        }
        final cuerpo = switch (seccion) {
          Seccion.clases => const InicioTab(),
          Seccion.favoritos => const FavoritosTab(),
          Seccion.descargas => const DescargasTab(),
          Seccion.administrar => const AdminPanelTab(),
          Seccion.perfil => const PerfilTab(),
        };
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: cuerpo,
            ),
          ),
          bottomNavigationBar: MenuInferior(activa: seccion),
        );
      },
    );
  }
}
