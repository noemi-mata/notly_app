enum EstadoReporte { pendiente, conservado, eliminado }

class Reporte {
  Reporte({
    required this.id,
    required this.apunteId,
    required this.reportanteId,
    required this.motivo,
    this.estado = EstadoReporte.pendiente,
  });

  final String id;
  final String apunteId;
  final String reportanteId;
  final String motivo;
  EstadoReporte estado;

  Map<String, dynamic> toJson() => {
        'id': id,
        'apunteId': apunteId,
        'reportanteId': reportanteId,
        'motivo': motivo,
        'estado': estado.name,
      };

  factory Reporte.fromJson(Map<String, dynamic> j) => Reporte(
        id: j['id'] as String,
        apunteId: j['apunteId'] as String,
        reportanteId: j['reportanteId'] as String,
        motivo: j['motivo'] as String,
        estado: EstadoReporte.values.byName(j['estado'] as String),
      );
}
