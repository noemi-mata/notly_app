import 'package:flutter/material.dart';

import '../modelos/clase.dart';
import 'clase_view.dart';

/// Abre una clase. La ruta se llama "clase" para poder regresar a ella
/// después de subir un apunte.
void abrirClase(BuildContext context, Clase clase) {
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: const RouteSettings(name: 'clase'),
      builder: (_) => ClaseView(claseId: clase.id),
    ),
  );
}

void volverAClase(NavigatorState nav) {
  nav.popUntil((r) => r.settings.name == 'clase' || r.isFirst);
}
