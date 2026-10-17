import 'package:flutter/material.dart';

class Clase {
  Clase({
    required this.id,
    required this.nombre,
    required this.grupo,
    required this.codigo,
    required this.iniciales,
    required this.color,
    this.docente = '',
    this.esAdmin = false,
    this.oculta = false,
  });

  final String id;
  final String nombre;
  final String grupo;
  final String codigo;
  final String iniciales;
  final Color color;
  final String docente;

  /// true si el usuario creó la clase (administrador de la clase).
  final bool esAdmin;

  /// true si el usuario ocultó la clase de su inicio.
  bool oculta;

  String get detalle =>
      docente.isEmpty ? 'Grupo $grupo' : 'Grupo $grupo · Doc. $docente';
}
