import 'package:flutter/material.dart';

class Clase {
  Clase({
    required this.id,
    required this.nombre,
    required this.grupo,
    required this.codigo,
    required this.creadorId,
    required this.color,
    this.docente = '',
    this.privada = false,
  });

  final String id;
  final String nombre;
  final String grupo;
  final String codigo;
  final String creadorId;
  final Color color;
  final String docente;

  /// Pública: entra cualquiera con el código.
  /// Privada: quien quiera entrar envía una solicitud que el administrador
  /// de la clase aprueba o rechaza.
  bool privada;

  /// Ids de los usuarios que pertenecen a la clase.
  final Set<String> miembros = {};

  /// Ids de los usuarios que ocultaron la clase de su inicio.
  final Set<String> ocultaPara = {};

  static String inicialesDe(String nombre) {
    final palabras = nombre.split(' ').where((p) => p.length > 2).toList();
    if (palabras.isEmpty) {
      return nombre.isEmpty ? '?' : nombre[0].toUpperCase();
    }
    return palabras.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get iniciales => inicialesDe(nombre);

  String get detalle =>
      docente.isEmpty ? 'Grupo $grupo' : 'Grupo $grupo · Doc. $docente';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'grupo': grupo,
        'codigo': codigo,
        'creadorId': creadorId,
        'color': color.toARGB32(),
        'docente': docente,
        'privada': privada,
        'miembros': miembros.toList(),
        'ocultaPara': ocultaPara.toList(),
      };

  factory Clase.fromJson(Map<String, dynamic> j) => Clase(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        grupo: j['grupo'] as String,
        codigo: j['codigo'] as String,
        creadorId: j['creadorId'] as String,
        color: Color(j['color'] as int),
        docente: (j['docente'] ?? '') as String,
        privada: (j['privada'] ?? false) as bool,
      )
        ..miembros.addAll(List<String>.from(j['miembros'] as List))
        ..ocultaPara.addAll(List<String>.from(j['ocultaPara'] as List));
}
