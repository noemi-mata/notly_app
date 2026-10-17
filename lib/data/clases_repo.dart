import 'package:flutter/foundation.dart';

import '../modelos/apunte.dart';
import '../modelos/clase.dart';
import '../tema/app_theme.dart';

/// Datos de demostración en memoria.
/// TODO: reemplazar por la base de datos / API cuando se implemente.
class ClasesRepo extends ChangeNotifier {
  ClasesRepo._();
  static final ClasesRepo instance = ClasesRepo._();

  final List<Clase> _clases = [
    Clase(
      id: 'dam',
      nombre: 'Desarrollo de Aplicaciones Móviles',
      grupo: 'GTID244',
      docente: 'Anastacio Rodríguez García',
      codigo: 'GTID244-DAM',
      iniciales: 'DA',
      color: AppColores.morado,
      esAdmin: true,
    ),
    Clase(
      id: 'ing',
      nombre: 'Inglés Técnico',
      grupo: 'GTID244',
      codigo: 'GTID244-ING',
      iniciales: 'IT',
      color: AppColores.rosa,
    ),
    Clase(
      id: 'cal',
      nombre: 'Cálculo Integral',
      grupo: 'GTID244',
      codigo: 'GTID244-CAL',
      iniciales: 'CI',
      color: AppColores.verde,
      oculta: true,
    ),
  ];

  /// Clases a las que el usuario todavía no se une (para probar el código).
  final List<Clase> _catalogo = [
    Clase(
      id: 'bd',
      nombre: 'Bases de Datos',
      grupo: 'GTID244',
      codigo: 'GTID244-BD',
      iniciales: 'BD',
      color: AppColores.terracota,
    ),
  ];

  final List<Apunte> _apuntes = const [
    Apunte(id: 'a1', claseId: 'dam', tema: 'Álgebra - Tema 3', materia: 'Matemáticas', autor: 'Ana', tipo: TipoArchivo.pdf),
    Apunte(id: 'a2', claseId: 'dam', tema: 'Enlaces químicos', materia: 'Química', autor: 'Noemi', tipo: TipoArchivo.img),
    Apunte(id: 'a3', claseId: 'dam', tema: 'Geometría - Repaso', materia: 'Matemáticas', autor: 'Luis', tipo: TipoArchivo.pdf),
    Apunte(id: 'a4', claseId: 'dam', tema: 'Present Perfect', materia: 'Inglés', autor: 'Karla', tipo: TipoArchivo.doc),
    Apunte(id: 'a5', claseId: 'dam', tema: 'Leyes de Newton', materia: 'Física', autor: 'Ana', tipo: TipoArchivo.pdf),
    Apunte(id: 'b1', claseId: 'ing', tema: 'Vocabulario técnico', materia: 'Inglés', autor: 'Karla', tipo: TipoArchivo.pdf),
    Apunte(id: 'b2', claseId: 'ing', tema: 'Reading practice', materia: 'Inglés', autor: 'Luis', tipo: TipoArchivo.doc),
    Apunte(id: 'b3', claseId: 'ing', tema: 'Email formal', materia: 'Inglés', autor: 'Ana', tipo: TipoArchivo.img),
    Apunte(id: 'c1', claseId: 'cal', tema: 'Integrales básicas', materia: 'Matemáticas', autor: 'Luis', tipo: TipoArchivo.pdf),
    Apunte(id: 'c2', claseId: 'cal', tema: 'Método de sustitución', materia: 'Matemáticas', autor: 'Ana', tipo: TipoArchivo.img),
  ];

  List<Clase> get visibles => _clases.where((c) => !c.oculta).toList();
  List<Clase> get ocultas => _clases.where((c) => c.oculta).toList();

  /// El menú muestra "Administrar" solo si el usuario creó alguna clase.
  bool get esAdminDeAlguna => _clases.any((c) => c.esAdmin);

  List<Apunte> apuntesDe(String claseId) =>
      _apuntes.where((a) => a.claseId == claseId).toList();

  Clase? buscarPorCodigo(String codigo) {
    final buscado = codigo.trim().toUpperCase();
    for (final c in [..._clases, ..._catalogo]) {
      if (c.codigo.toUpperCase() == buscado) return c;
    }
    return null;
  }

  bool yaPertenece(Clase clase) => _clases.any((c) => c.id == clase.id);

  void unirse(Clase clase) {
    if (yaPertenece(clase)) return;
    _clases.add(clase);
    notifyListeners();
  }

  void ocultar(Clase clase) {
    clase.oculta = true;
    notifyListeners();
  }

  void mostrar(Clase clase) {
    clase.oculta = false;
    notifyListeners();
  }
}
