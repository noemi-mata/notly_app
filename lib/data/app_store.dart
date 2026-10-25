import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/apunte.dart';
import '../modelos/clase.dart';
import '../modelos/materia.dart';
import '../modelos/reporte.dart';
import '../modelos/solicitud.dart';
import '../modelos/usuario.dart';
import '../widgets/app_tema.dart';
import 'archivos_service.dart';
import 'muestras_service.dart';

/// Almacén de datos de la app. Todo se guarda en el dispositivo
/// (SharedPreferences), así los datos siguen ahí al cerrar y abrir la app.
class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  static const _clave = 'notly_datos_v2';

  int _contador = 100;
  String _nuevoId(String prefijo) => '$prefijo${_contador++}';

  final List<Usuario> usuarios = [];
  final List<Clase> clases = [];
  final List<Materia> materias = [];
  final List<Apunte> apuntes = [];
  final List<Reporte> reportes = [];
  final List<Solicitud> solicitudes = [];
  final Map<String, List<String>> _descargas = {};
  final Map<String, Set<String>> _favoritos = {};
  final Map<String, List<String>> _rutasDescargadas = {};

  Usuario? usuarioActual;

  /// Rol con el que se está usando la app ahora mismo.
  /// - alumno: entra a clases, ve/sube/descarga apuntes (sin "Administrar").
  /// - docente: crea y administra sus propias clases.
  /// - administrador: todo lo anterior y además gestiona usuarios y todas las clases.
  ModoUsuario modo = ModoUsuario.alumno;

  bool get modoAdministrador => modo == ModoUsuario.administrador;

  /// Las cuentas normales alternan entre alumno y docente.
  /// Las cuentas de administrador solo tienen el rol administrador.
  List<ModoUsuario> get modosDisponibles {
    final u = usuarioActual;
    if (u == null) return const [];
    return u.esAdministrador
        ? const [ModoUsuario.administrador]
        : const [ModoUsuario.alumno, ModoUsuario.docente];
  }

  /// Docente o administrador: puede crear y gestionar clases.
  bool get gestionaClases => modo != ModoUsuario.alumno;

  static const _paleta = [
    AppColores.morado,
    AppColores.rosa,
    AppColores.verde,
    AppColores.terracota,
    AppColores.primario,
  ];

  // ---------------------------------------------------------------- Guardado

  bool _cargado = false;

  /// Lee los datos guardados (o crea los de ejemplo la primera vez).
  Future<void> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString(_clave);
      if (texto != null) {
        _leer(jsonDecode(texto) as Map<String, dynamic>);
      }
    } catch (_) {
      usuarios.clear();
      clases.clear();
      materias.clear();
      apuntes.clear();
      reportes.clear();
      solicitudes.clear();
      _descargas.clear();
      _favoritos.clear();
      _rutasDescargadas.clear();
      usuarioActual = null;
    }
    if (usuarios.isEmpty) _sembrar();
    _cargado = true;
    await prepararMuestras();
    await _guardar();
  }

  void _leer(Map<String, dynamic> j) {
    List<Map<String, dynamic>> lista(String k) =>
        List<Map<String, dynamic>>.from((j[k] ?? []) as List);

    usuarios.addAll(lista('usuarios').map(Usuario.fromJson));
    clases.addAll(lista('clases').map(Clase.fromJson));
    materias.addAll(lista('materias').map(Materia.fromJson));
    apuntes.addAll(lista('apuntes').map(Apunte.fromJson));
    reportes.addAll(lista('reportes').map(Reporte.fromJson));
    solicitudes.addAll(lista('solicitudes').map(Solicitud.fromJson));

    ((j['descargas'] ?? {}) as Map<String, dynamic>).forEach((k, v) {
      _descargas[k] = List<String>.from(v as List);
    });
    ((j['favoritos'] ?? {}) as Map<String, dynamic>).forEach((k, v) {
      _favoritos[k] = Set<String>.from(v as List);
    });
    ((j['rutasDescargadas'] ?? {}) as Map<String, dynamic>).forEach((k, v) {
      _rutasDescargadas[k] = List<String>.from(v as List);
    });
    _contador = (j['contador'] ?? 100) as int;
    final uid = j['usuarioActual'] as String?;
    usuarioActual = uid == null ? null : usuarioPorId(uid);
    modo = ModoUsuario.values.firstWhere(
        (m) => m.name == j['modo'],
        orElse: () => ModoUsuario.alumno);
    final actual = usuarioActual;
    if (actual != null) {
      if (actual.esAdministrador) {
        modo = ModoUsuario.administrador;
      } else if (modo == ModoUsuario.administrador) {
        modo = ModoUsuario.alumno;
      }
    }
  }

  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datos = {
        'usuarios': usuarios.map((e) => e.toJson()).toList(),
        'clases': clases.map((e) => e.toJson()).toList(),
        'materias': materias.map((e) => e.toJson()).toList(),
        'apuntes': apuntes.map((e) => e.toJson()).toList(),
        'reportes': reportes.map((e) => e.toJson()).toList(),
        'solicitudes': solicitudes.map((e) => e.toJson()).toList(),
        'descargas': _descargas,
        'favoritos': _favoritos.map((k, v) => MapEntry(k, v.toList())),
        'rutasDescargadas': _rutasDescargadas,
        'contador': _contador,
        'usuarioActual': usuarioActual?.id,
        'modo': modo.name,
      };
      await prefs.setString(_clave, jsonEncode(datos));
    } catch (_) {
      // Si no se puede guardar, la app sigue funcionando con los datos en memoria.
    }
  }

  /// Cada cambio avisa a las pantallas y se guarda.
  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_cargado) _guardar();
  }

  // ---------------------------------------------------------------- Sesión

  String? iniciarSesion(String correo, String contrasena) {
    final c = correo.trim().toLowerCase();
    final u = usuarios.where((x) => x.correo.toLowerCase() == c).firstOrNull;
    if (u == null || u.contrasena != contrasena) {
      return 'Correo o contraseña incorrectos';
    }
    if (u.suspendido) {
      return 'Tu cuenta está suspendida. Contacta a un administrador';
    }
    usuarioActual = u;
    modo = u.esAdministrador ? ModoUsuario.administrador : ModoUsuario.alumno;
    notifyListeners();
    return null;
  }

  String? registrar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) {
    if (nombre.trim().isEmpty || correo.trim().isEmpty || contrasena.isEmpty) {
      return 'Completa todos los campos';
    }
    final mail = correo.trim();
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(mail);
    if (!valido) return 'Escribe un correo válido';
    if (contrasena.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    final repetido =
        usuarios.any((u) => u.correo.toLowerCase() == mail.toLowerCase());
    if (repetido) return 'Ya existe una cuenta con ese correo';

    final u = Usuario(
      id: _nuevoId('u'),
      nombre: nombre.trim(),
      correo: mail,
      contrasena: contrasena,
    );
    usuarios.add(u);
    usuarioActual = u;
    notifyListeners();
    return null;
  }

  void cambiarModo(ModoUsuario nuevo) {
    if (!modosDisponibles.contains(nuevo)) return;
    modo = nuevo;
    notifyListeners();
  }

  void cerrarSesion() {
    usuarioActual = null;
    modo = ModoUsuario.alumno;
    notifyListeners();
  }

  // ---------------------------------------------------------------- Consultas

  Usuario? usuarioPorId(String id) =>
      usuarios.where((u) => u.id == id).firstOrNull;
  Clase? clasePorId(String id) => clases.where((c) => c.id == id).firstOrNull;
  Materia? materiaPorId(String id) =>
      materias.where((m) => m.id == id).firstOrNull;
  Apunte? apuntePorId(String id) =>
      apuntes.where((a) => a.id == id).firstOrNull;

  String nombreAutor(String id) =>
      usuarioPorId(id)?.nombre.split(' ').first ?? '—';

  String nombreCompletoAutor(String id) => usuarioPorId(id)?.nombre ?? '';

  List<Materia> materiasDe(String claseId) =>
      materias.where((m) => m.claseId == claseId).toList();

  List<Apunte> apuntesDe(String claseId) =>
      apuntes.where((a) => a.claseId == claseId).toList();

  List<Apunte> subidosPor(String usuarioId) =>
      apuntes.where((a) => a.autorId == usuarioId).toList();

  /// Lo que se ve en el inicio depende del modo:
  /// - alumno: las clases a las que entró (no las que creó);
  /// - docente: las clases que creó;
  /// - administrador: todas las clases de Notly.
  List<Clase> get _clasesDelUsuario {
    final u = usuarioActual;
    if (u == null) return [];
    return clases
        .where((c) => switch (modo) {
              ModoUsuario.alumno =>
                c.miembros.contains(u.id) && c.creadorId != u.id,
              ModoUsuario.docente => c.creadorId == u.id,
              ModoUsuario.administrador => true,
            })
        .toList();
  }

  List<Clase> get clasesVisibles => _clasesDelUsuario
      .where((c) => !c.ocultaPara.contains(usuarioActual!.id))
      .toList();

  List<Clase> get clasesOcultas => _clasesDelUsuario
      .where((c) => c.ocultaPara.contains(usuarioActual!.id))
      .toList();

  /// Alumnos inscritos: todos los miembros menos quien creó la clase.
  List<Usuario> alumnosDe(Clase c) => c.miembros
      .where((id) => id != c.creadorId)
      .map(usuarioPorId)
      .whereType<Usuario>()
      .toList();

  List<Clase> get clasesCreadas {
    final u = usuarioActual;
    if (u == null) return [];
    return clases.where((c) => c.creadorId == u.id).toList();
  }

  bool esCreador(Clase c) => c.creadorId == usuarioActual?.id;

  bool get esAdministradorGeneral => usuarioActual?.esAdministrador ?? false;

  /// Administrar una clase: el administrador cualquiera; el docente las suyas;
  /// el alumno ninguna.
  bool puedeAdministrar(Clase c) =>
      modo == ModoUsuario.administrador ||
      (modo == ModoUsuario.docente && esCreador(c));

  bool esMiembro(Clase c) => c.miembros.contains(usuarioActual?.id ?? '');

  /// Roles de la cuenta: alumno y docente, o solo administrador.
  List<ModoUsuario> get rolesDelUsuario => modosDisponibles;

  // ---------------------------------------------------------------- Clases

  void ocultar(Clase c) {
    c.ocultaPara.add(usuarioActual!.id);
    notifyListeners();
  }

  void mostrar(Clase c) {
    c.ocultaPara.remove(usuarioActual!.id);
    notifyListeners();
  }

  Clase? buscarPorCodigo(String codigo) {
    final buscado = codigo.trim().toUpperCase();
    if (buscado.isEmpty) return null;
    return clases.where((c) => c.codigo.toUpperCase() == buscado).firstOrNull;
  }

  /// Entrada directa (solo clases públicas).
  void unirse(Clase c) {
    if (c.privada || modo != ModoUsuario.alumno) return;
    c.miembros.add(usuarioActual!.id);
    notifyListeners();
  }

  Clase crearClase({
    required String nombre,
    required String grupo,
    String docente = '',
    bool privada = false,
  }) {
    final u = usuarioActual!;
    final base =
        '${grupo.trim().toUpperCase()}-${Clase.inicialesDe(nombre.trim())}';
    var codigo = base;
    var n = 2;
    while (buscarPorCodigo(codigo) != null) {
      codigo = '$base$n';
      n++;
    }
    final c = Clase(
      id: _nuevoId('c'),
      nombre: nombre.trim(),
      grupo: grupo.trim().toUpperCase(),
      codigo: codigo,
      creadorId: u.id,
      color: _paleta[clases.length % _paleta.length],
      docente: docente.trim(),
      privada: privada,
    )..miembros.add(u.id);
    clases.add(c);
    notifyListeners();
    return c;
  }

  /// El administrador saca a una persona de la clase (no al creador).
  void sacarDeClase(Clase c, Usuario u) {
    if (u.id == c.creadorId) return;
    c.miembros.remove(u.id);
    c.ocultaPara.remove(u.id);
    notifyListeners();
  }

  void cambiarPrivacidad(Clase c, bool privada) {
    c.privada = privada;
    notifyListeners();
  }

  void eliminarClase(String id) {
    final idsApuntes =
        apuntes.where((a) => a.claseId == id).map((a) => a.id).toSet();
    reportes.removeWhere((r) => idsApuntes.contains(r.apunteId));
    for (final aId in idsApuntes) {
      _rutasDescargadas.remove(aId);
      ArchivosService.borrarCarpeta('apuntes/$aId');
      ArchivosService.borrarCarpeta('descargas/$aId');
      ArchivosService.borrarCarpeta('muestras/$aId');
    }
    apuntes.removeWhere((a) => a.claseId == id);
    materias.removeWhere((m) => m.claseId == id);
    solicitudes.removeWhere((s) => s.claseId == id);
    clases.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String? agregarMateria(String claseId, String nombre,
      {bool esUnidad = false}) {
    final clase = clasePorId(claseId);
    if (clase == null || !puedeAdministrar(clase)) {
      return 'Solo el docente o administrador de la clase puede agregar materias y unidades';
    }
    final n = nombre.trim();
    if (n.isEmpty) {
      return esUnidad
          ? 'Escribe el nombre de la unidad'
          : 'Escribe el nombre de la materia';
    }
    final existe = materiasDe(claseId)
        .any((m) => m.nombre.toLowerCase() == n.toLowerCase());
    if (existe) return 'Ya existe una materia o unidad con ese nombre en la clase';
    materias.add(Materia(
        id: _nuevoId('m'), claseId: claseId, nombre: n, esUnidad: esUnidad));
    notifyListeners();
    return null;
  }

  // ---------------------------------------------------------------- Solicitudes (clases privadas)

  /// Última solicitud del usuario actual para esa clase.
  Solicitud? solicitudDe(Clase c) {
    final uid = usuarioActual?.id;
    final mias = solicitudes
        .where((s) => s.claseId == c.id && s.usuarioId == uid)
        .toList();
    return mias.isEmpty ? null : mias.last;
  }

  /// Envía la solicitud de ingreso a una clase privada.
  String? solicitar(Clase c) {
    if (modo != ModoUsuario.alumno) return 'Solo los alumnos pueden unirse a clases';
    if (esMiembro(c)) return 'Ya perteneces a esta clase';
    final actual = solicitudDe(c);
    if (actual != null && actual.estado == EstadoSolicitud.pendiente) {
      return 'Ya enviaste una solicitud, espera la respuesta';
    }
    solicitudes.add(Solicitud(
      id: _nuevoId('s'),
      claseId: c.id,
      usuarioId: usuarioActual!.id,
      fecha: DateTime.now(),
    ));
    notifyListeners();
    return null;
  }

  List<Solicitud> solicitudesPendientesDe(Clase c) => solicitudes
      .where((s) => s.claseId == c.id && s.estado == EstadoSolicitud.pendiente)
      .toList();

  /// Solicitudes pendientes de todas las clases que el usuario administra.
  List<Solicitud> get solicitudesPorResponder {
    final ids = clasesAdministrables.map((c) => c.id).toSet();
    return solicitudes
        .where((s) =>
            s.estado == EstadoSolicitud.pendiente && ids.contains(s.claseId))
        .toList();
  }

  /// Solicitudes que el usuario actual envió y siguen pendientes o fueron rechazadas.
  List<Solicitud> get misSolicitudesAbiertas {
    final uid = usuarioActual?.id;
    return solicitudes
        .where((s) =>
            s.usuarioId == uid &&
            s.estado != EstadoSolicitud.aprobada &&
            clasePorId(s.claseId) != null)
        .toList();
  }

  void responderSolicitud(Solicitud s, {required bool aprobar}) {
    s.estado = aprobar ? EstadoSolicitud.aprobada : EstadoSolicitud.rechazada;
    if (aprobar) clasePorId(s.claseId)?.miembros.add(s.usuarioId);
    notifyListeners();
  }

  /// Quita de la lista una solicitud rechazada ya vista.
  void descartarSolicitud(Solicitud s) {
    solicitudes.remove(s);
    notifyListeners();
  }

  // ---------------------------------------------------------------- Apuntes

  Future<Apunte> subirApunte({
    required String claseId,
    required String materiaId,
    required String tema,
    String descripcion = '',
    required String nombreArchivo,
    required double tamanoMb,
    required int paginas,
    List<String> rutas = const [],
  }) async {
    final id = _nuevoId('a');
    final guardadas = rutas.isEmpty
        ? <String>[]
        : await ArchivosService.copiar(rutas, 'apuntes/$id');
    final a = Apunte(
      id: id,
      claseId: claseId,
      materiaId: materiaId,
      tema: tema.trim(),
      descripcion: descripcion.trim(),
      autorId: usuarioActual!.id,
      nombreArchivo: nombreArchivo,
      tamanoMb: tamanoMb,
      paginas: paginas,
      fecha: DateTime.now(),
      rutas: guardadas,
    );
    apuntes.insert(0, a);
    notifyListeners();
    return a;
  }

  void eliminarApunte(String id) {
    apuntes.removeWhere((a) => a.id == id);
    _rutasDescargadas.remove(id);
    ArchivosService.borrarCarpeta('apuntes/$id');
    ArchivosService.borrarCarpeta('descargas/$id');
    ArchivosService.borrarCarpeta('muestras/$id');
    for (final r in reportes) {
      if (r.apunteId == id && r.estado == EstadoReporte.pendiente) {
        r.estado = EstadoReporte.eliminado;
      }
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- Descargas y favoritos

  List<String> rutasDescargadas(String apunteId) =>
      _rutasDescargadas[apunteId] ?? const [];

  Future<void> registrarDescarga(Apunte a) async {
    if (a.rutas.isNotEmpty && rutasDescargadas(a.id).isEmpty) {
      try {
        _rutasDescargadas[a.id] =
            await ArchivosService.copiar(a.rutas, 'descargas/${a.id}');
      } catch (_) {}
    }
    final lista = _descargas.putIfAbsent(usuarioActual!.id, () => []);
    lista.remove(a.id);
    lista.insert(0, a.id);
    notifyListeners();
  }

  List<Apunte> get descargasDelUsuario {
    final ids = _descargas[usuarioActual?.id] ?? const <String>[];
    return [
      for (final id in ids)
        if (apuntePorId(id) != null) apuntePorId(id)!,
    ];
  }

  bool esFavorito(Apunte a) =>
      (_favoritos[usuarioActual?.id] ?? const <String>{}).contains(a.id);

  void alternarFavorito(Apunte a) {
    final set = _favoritos.putIfAbsent(usuarioActual!.id, () => {});
    if (!set.add(a.id)) set.remove(a.id);
    notifyListeners();
  }

  List<Apunte> get favoritosDelUsuario => apuntes.where(esFavorito).toList();

  // ---------------------------------------------------------------- Moderación

  bool reportar(Apunte a, String motivo) {
    final u = usuarioActual!;
    final yaReportado = reportes.any((r) =>
        r.apunteId == a.id &&
        r.reportanteId == u.id &&
        r.estado == EstadoReporte.pendiente);
    if (yaReportado) return false;
    reportes.add(Reporte(
      id: _nuevoId('r'),
      apunteId: a.id,
      reportanteId: u.id,
      motivo: motivo,
    ));
    notifyListeners();
    return true;
  }

  List<Reporte> get reportesPendientes => reportes
      .where((r) =>
          r.estado == EstadoReporte.pendiente &&
          apuntePorId(r.apunteId) != null)
      .toList();

  void conservarApunte(Reporte r) {
    r.estado = EstadoReporte.conservado;
    notifyListeners();
  }

  void eliminarPorReporte(Reporte r, {bool suspenderAutor = false}) {
    final a = apuntePorId(r.apunteId);
    if (a != null && suspenderAutor) {
      final autor = usuarioPorId(a.autorId);
      if (autor != null && !autor.esAdministrador) {
        autor.suspendido = true;
      }
    }
    eliminarApunte(r.apunteId);
  }

  List<Reporte> get reportesModerables {
    final ids = clasesAdministrables.map((c) => c.id).toSet();
    return reportesPendientes
        .where((r) => ids.contains(apuntePorId(r.apunteId)?.claseId))
        .toList();
  }

  // ---------------------------------------------------------------- Usuarios (administrador general)

  /// El administrador da el rol de administrador a otra cuenta.
  String? hacerAdministrador(Usuario u) {
    if (!esAdministradorGeneral) {
      return 'Solo un administrador puede hacer esto';
    }
    if (u.esAdministrador) return '${u.nombre} ya es administrador';
    u.esAdministrador = true;
    u.suspendido = false;
    notifyListeners();
    return null;
  }

  /// Le quita el rol de administrador a otra cuenta (nunca a sí mismo).
  String? quitarAdministrador(Usuario u) {
    if (!esAdministradorGeneral) {
      return 'Solo un administrador puede hacer esto';
    }
    if (u.id == usuarioActual?.id) {
      return 'No puedes quitarte el rol a ti mismo';
    }
    u.esAdministrador = false;
    notifyListeners();
    return null;
  }

  void alternarSuspension(Usuario u) {
    u.suspendido = !u.suspendido;
    notifyListeners();
  }

  // ---------------------------------------------------------------- Permisos

  /// Solo el docente crea clases (y es su administrador).
  bool get puedeCrearClases =>
      usuarioActual != null && modo == ModoUsuario.docente;

  /// "Administrar" solo aparece cuando la persona cambia a modo administrador.
  bool get mostrarAdministrar => usuarioActual != null && gestionaClases;

  /// Administrador general: todas las clases. Los demás: las que crearon.
  List<Clase> get clasesAdministrables =>
      switch (modo) {
        ModoUsuario.administrador => List.of(clases),
        ModoUsuario.docente => clasesCreadas,
        ModoUsuario.alumno => <Clase>[],
      };

  // ---------------------------------------------------------------- Archivos de ejemplo

  /// Crea los archivos reales (PDF e imágenes) de los apuntes de ejemplo.
  Future<void> prepararMuestras() async {
    for (final a in apuntes) {
      if (!a.id.startsWith(RegExp(r'[abc]\d$'))) continue; // solo los de ejemplo
      final n = a.nombreArchivo.toLowerCase();
      if (!(n.endsWith('.pdf') || n.endsWith('.png'))) continue;
      if (a.rutas.isNotEmpty && ArchivosService.existe(a.rutas.first)) continue;
      try {
        a.rutas = await MuestrasService.crear(
          id: a.id,
          nombreArchivo: a.nombreArchivo,
          titulo: a.tema,
          materia: materiaPorId(a.materiaId)?.nombre ?? '',
          paginas: a.paginas,
        );
      } catch (_) {
        a.rutas = [];
      }
    }
  }

  // ---------------------------------------------------------------- Datos de ejemplo

  void _sembrar() {
    usuarios.addAll([
      Usuario(id: 'u1', nombre: 'Noemi Mata Ruiz', matricula: '1225100341', correo: 'noemi@gmail.com', contrasena: '12345678'),
      Usuario(id: 'u2', nombre: 'Ana Torres', matricula: '1225100412', correo: 'ana@gmail.com', contrasena: '12345678'),
      Usuario(id: 'u3', nombre: 'Luis Pérez', matricula: '1225100523', correo: 'luis@gmail.com', contrasena: '12345678'),
      Usuario(id: 'u4', nombre: 'Karla Núñez', matricula: '1225100634', correo: 'karla@gmail.com', contrasena: '12345678'),
      Usuario(id: 'd1', nombre: 'Anastacio Rodríguez García', correo: 'docente@gmail.com', contrasena: 'docente123'),
      Usuario(id: 'ad1', nombre: 'Administrador General', correo: 'admin@gmail.com', contrasena: 'admin123', esAdministrador: true),
    ]);

    final dam = Clase(id: 'dam', nombre: 'Desarrollo de Aplicaciones Móviles', grupo: 'GTID244', codigo: 'GTID244-DAM', creadorId: 'd1', color: AppColores.morado, docente: 'Anastacio Rodríguez García')
      ..miembros.addAll(['d1', 'u1', 'u2', 'u3', 'u4']);
    final ing = Clase(id: 'ing', nombre: 'Inglés Técnico', grupo: 'GTID244', codigo: 'GTID244-ING', creadorId: 'd1', color: AppColores.rosa, privada: true)
      ..miembros.addAll(['d1', 'u1', 'u2']);
    final cal = Clase(id: 'cal', nombre: 'Cálculo Integral', grupo: 'GTID244', codigo: 'GTID244-CAL', creadorId: 'd1', color: AppColores.verde)
      ..miembros.addAll(['d1', 'u1'])
      ..ocultaPara.add('u1');
    final bd = Clase(id: 'bd', nombre: 'Bases de Datos', grupo: 'GTID244', codigo: 'GTID244-BD', creadorId: 'd1', color: AppColores.terracota, privada: true)
      ..miembros.add('d1');
    clases.addAll([dam, ing, cal, bd]);

    materias.addAll(const [
      Materia(id: 'm1', claseId: 'dam', nombre: 'Matemáticas'),
      Materia(id: 'm2', claseId: 'dam', nombre: 'Química'),
      Materia(id: 'm3', claseId: 'dam', nombre: 'Inglés'),
      Materia(id: 'm4', claseId: 'dam', nombre: 'Física'),
      Materia(id: 'm5', claseId: 'ing', nombre: 'Inglés'),
      Materia(id: 'm6', claseId: 'cal', nombre: 'Matemáticas'),
      Materia(id: 'm7', claseId: 'bd', nombre: 'Modelado de datos'),
    ]);

    Apunte ap(String id, String clase, String materia, String tema, String autor,
            String archivo, double mb, int pags, int dia) =>
        Apunte(
          id: id,
          claseId: clase,
          materiaId: materia,
          tema: tema,
          autorId: autor,
          nombreArchivo: archivo,
          tamanoMb: mb,
          paginas: pags,
          fecha: DateTime(2026, 10, dia),
        );

    apuntes.addAll([
      ap('a1', 'dam', 'm1', 'Álgebra - Tema 3', 'u2', 'Algebra-Tema3.pdf', 1.4, 2, 20),
      ap('a2', 'dam', 'm2', 'Enlaces químicos', 'u1', 'Enlaces.png', 2.0, 1, 19),
      ap('a3', 'dam', 'm1', 'Geometría - Repaso', 'u3', 'Geometria-Repaso.pdf', 1.1, 3, 18),
      ap('a4', 'dam', 'm3', 'Present Perfect', 'u4', 'Present-Perfect.docx', 0.5, 2, 17),
      ap('a5', 'dam', 'm4', 'Leyes de Newton', 'u2', 'Leyes-Newton.pdf', 1.8, 4, 16),
      ap('b1', 'ing', 'm5', 'Vocabulario técnico', 'u4', 'Vocabulario.pdf', 0.9, 2, 15),
      ap('b2', 'ing', 'm5', 'Reading practice', 'u3', 'Reading.docx', 0.4, 1, 14),
      ap('b3', 'ing', 'm5', 'Email formal', 'u2', 'Email.png', 1.2, 1, 13),
      ap('c1', 'cal', 'm6', 'Integrales básicas', 'u3', 'Integrales.pdf', 1.6, 3, 12),
      ap('c2', 'cal', 'm6', 'Método de sustitución', 'u2', 'Sustitucion.png', 1.3, 1, 11),
    ]);

    reportes.add(Reporte(id: 'r1', apunteId: 'a1', reportanteId: 'u3', motivo: 'Contenido ajeno a la materia'));
    reportes.add(Reporte(id: 'r2', apunteId: 'a2', reportanteId: 'u4', motivo: 'Archivo ilegible'));
    reportes.add(Reporte(id: 'r3', apunteId: 'a4', reportanteId: 'u2', motivo: 'Contenido duplicado'));

    // Ejemplo de solicitud a una clase privada (Luis quiere entrar a Inglés Técnico).
    solicitudes.add(Solicitud(id: 's1', claseId: 'ing', usuarioId: 'u3', fecha: DateTime(2026, 10, 22)));
  }
}
