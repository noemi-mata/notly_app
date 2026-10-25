/// Los tres roles de la app. Cada cuenta puede cambiar entre ellos
/// desde el menú de la esquina.
enum ModoUsuario { alumno, docente, administrador }

extension ModoUsuarioX on ModoUsuario {
  String get etiqueta => switch (this) {
        ModoUsuario.alumno => 'Alumno',
        ModoUsuario.docente => 'Docente',
        ModoUsuario.administrador => 'Administrador',
      };
}

/// Una sola cuenta sirve para todo: cualquiera puede estudiar, crear clases
/// (y ser su administrador/docente) y, si lo asigna un administrador general,
/// administrar toda la app.
class Usuario {
  Usuario({
    required this.id,
    required this.nombre,
    this.matricula = '',
    required this.correo,
    required this.contrasena,
    this.esAdministrador = false,
    this.suspendido = false,
  });

  final String id;
  final String nombre;
  final String matricula;
  final String correo;
  final String contrasena;

  /// Administrador general de Notly.
  bool esAdministrador;
  bool suspendido;

  String get iniciales {
    final partes =
        nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (partes.isEmpty) return '?';
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'matricula': matricula,
        'correo': correo,
        'contrasena': contrasena,
        'esAdministrador': esAdministrador,
        'suspendido': suspendido,
      };

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        matricula: (j['matricula'] ?? '') as String,
        correo: j['correo'] as String,
        contrasena: j['contrasena'] as String,
        esAdministrador: (j['esAdministrador'] ?? false) as bool,
        suspendido: (j['suspendido'] ?? false) as bool,
      );
}
