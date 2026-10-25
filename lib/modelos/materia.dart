/// Una materia o una unidad dentro de una clase.
class Materia {
  const Materia({
    required this.id,
    required this.claseId,
    required this.nombre,
    this.esUnidad = false,
  });

  final String id;
  final String claseId;
  final String nombre;
  final bool esUnidad;

  String get tipo => esUnidad ? 'Unidad' : 'Materia';

  Map<String, dynamic> toJson() => {
        'id': id,
        'claseId': claseId,
        'nombre': nombre,
        'esUnidad': esUnidad,
      };

  factory Materia.fromJson(Map<String, dynamic> j) => Materia(
        id: j['id'] as String,
        claseId: j['claseId'] as String,
        nombre: j['nombre'] as String,
        esUnidad: (j['esUnidad'] ?? false) as bool,
      );
}
