enum EstadoSolicitud { pendiente, aprobada, rechazada }

/// Petición para entrar a una clase privada.
class Solicitud {
  Solicitud({
    required this.id,
    required this.claseId,
    required this.usuarioId,
    required this.fecha,
    this.estado = EstadoSolicitud.pendiente,
  });

  final String id;
  final String claseId;
  final String usuarioId;
  final DateTime fecha;
  EstadoSolicitud estado;

  Map<String, dynamic> toJson() => {
        'id': id,
        'claseId': claseId,
        'usuarioId': usuarioId,
        'fecha': fecha.toIso8601String(),
        'estado': estado.name,
      };

  factory Solicitud.fromJson(Map<String, dynamic> j) => Solicitud(
        id: j['id'] as String,
        claseId: j['claseId'] as String,
        usuarioId: j['usuarioId'] as String,
        fecha: DateTime.parse(j['fecha'] as String),
        estado: EstadoSolicitud.values.byName(j['estado'] as String),
      );
}
