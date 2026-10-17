import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

enum TipoArchivo { pdf, img, doc }

extension TipoArchivoX on TipoArchivo {
  String get etiqueta => switch (this) {
        TipoArchivo.pdf => 'PDF',
        TipoArchivo.img => 'IMG',
        TipoArchivo.doc => 'DOC',
      };

  Color get color => switch (this) {
        TipoArchivo.pdf => AppColores.terracota,
        TipoArchivo.img => AppColores.verde,
        TipoArchivo.doc => AppColores.primario,
      };
}

class Apunte {
  const Apunte({
    required this.id,
    required this.claseId,
    required this.tema,
    required this.materia,
    required this.autor,
    required this.tipo,
  });

  final String id;
  final String claseId;
  final String tema;
  final String materia;
  final String autor;
  final TipoArchivo tipo;
}
