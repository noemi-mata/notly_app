import 'package:flutter/material.dart';

import '../widgets/app_tema.dart';

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

TipoArchivo tipoDesdeNombre(String nombre) {
  final n = nombre.toLowerCase();
  if (n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png')) {
    return TipoArchivo.img;
  }
  if (n.endsWith('.docx') || n.endsWith('.doc')) return TipoArchivo.doc;
  return TipoArchivo.pdf;
}

/// Formatos aceptados: PDF, JPG, PNG y DOCX.
bool formatoValido(String nombre) {
  final n = nombre.toLowerCase();
  return ['.pdf', '.jpg', '.jpeg', '.png', '.docx'].any(n.endsWith);
}

class Apunte {
  Apunte({
    required this.id,
    required this.claseId,
    required this.materiaId,
    required this.tema,
    required this.autorId,
    required this.nombreArchivo,
    required this.tamanoMb,
    required this.paginas,
    required this.fecha,
    this.descripcion = '',
    this.rutas = const [],
  });

  final String id;
  final String claseId;
  final String materiaId;
  final String tema;
  final String descripcion;
  final String autorId;
  final String nombreArchivo;
  final double tamanoMb;
  final int paginas;
  final DateTime fecha;

  /// Archivos reales guardados en el teléfono (vacío en los apuntes de ejemplo).
  List<String> rutas;

  bool get tieneArchivo => rutas.isNotEmpty;

  TipoArchivo get tipo => tipoDesdeNombre(nombreArchivo);

  Map<String, dynamic> toJson() => {
        'id': id,
        'claseId': claseId,
        'materiaId': materiaId,
        'tema': tema,
        'descripcion': descripcion,
        'autorId': autorId,
        'nombreArchivo': nombreArchivo,
        'tamanoMb': tamanoMb,
        'paginas': paginas,
        'fecha': fecha.toIso8601String(),
        'rutas': rutas,
      };

  factory Apunte.fromJson(Map<String, dynamic> j) => Apunte(
        id: j['id'] as String,
        claseId: j['claseId'] as String,
        materiaId: j['materiaId'] as String,
        tema: j['tema'] as String,
        descripcion: (j['descripcion'] ?? '') as String,
        autorId: j['autorId'] as String,
        nombreArchivo: j['nombreArchivo'] as String,
        tamanoMb: (j['tamanoMb'] as num).toDouble(),
        paginas: j['paginas'] as int,
        fecha: DateTime.parse(j['fecha'] as String),
        rutas: List<String>.from(j['rutas'] as List),
      );
}
