import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'acciones_apunte.dart';
import 'agregar_apunte_view.dart';
import 'agregar_materia_view.dart';
import 'alumnos_clase_view.dart';
import 'codigo_clase.dart';
import 'opciones_clase_view.dart';

class ClaseView extends StatefulWidget {
  const ClaseView({super.key, required this.claseId});

  final String claseId;

  @override
  State<ClaseView> createState() => _ClaseViewState();
}

class _ClaseViewState extends State<ClaseView> {
  final _buscar = TextEditingController();
  String? _materiaId; // null = todas

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final clase = store.clasePorId(widget.claseId);

        if (clase == null) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Encabezado(titulo: 'Clase'),
                    Expanded(child: EstadoVacio('Esta clase ya no existe')),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: MenuInferior(),
          );
        }

        final admin = store.puedeAdministrar(clase);
        final puedeSubir = store.esMiembro(clase) || admin;
        final materias = store.materiasDe(clase.id);
        final q = _buscar.text.trim().toLowerCase();
        final apuntes = store.apuntesDe(clase.id).where((a) {
          final okMateria = _materiaId == null || a.materiaId == _materiaId;
          final okTexto = q.isEmpty ||
              a.tema.toLowerCase().contains(q) ||
              store.nombreCompletoAutor(a.autorId).toLowerCase().contains(q);
          return okMateria && okTexto;
        }).toList();

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Encabezado(
                    titulo: clase.nombre,
                    tamano: 19,
                    acciones: [
                      if (admin)
                        IconButton(
                          tooltip: 'Opciones de la clase',
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OpcionesClaseView(claseId: clase.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(clase.detalle,
                            style: const TextStyle(
                                fontSize: 13, color: AppColores.textoSuave)),
                      ),
                      IconButton(
                        tooltip: 'Ver o compartir el código de la clase',
                        icon: const Icon(Icons.vpn_key_outlined),
                        onPressed: () => mostrarCodigoClase(context, clase),
                      ),
                      // Solo el docente o administrador ve a los alumnos.
                      if (admin)
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AlumnosClaseView(claseId: clase.id),
                            ),
                          ),
                          icon: const Icon(Icons.people_outline, size: 18),
                          label: Text('Alumnos (${store.alumnosDe(clase).length})'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CampoBusqueda(
                    controller: _buscar,
                    hint: 'Buscar apunte o alumno…',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('Todas'),
                            selected: _materiaId == null,
                            onSelected: (_) =>
                                setState(() => _materiaId = null),
                          ),
                        ),
                        for (final m in materias)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                  m.esUnidad
                                      ? Icons.folder_outlined
                                      : Icons.menu_book_outlined,
                                  size: 16),
                              label: Text(m.nombre),
                              selected: _materiaId == m.id,
                              onSelected: (_) =>
                                  setState(() => _materiaId = m.id),
                            ),
                          ),
                        if (admin)
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('Materia o unidad'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AgregarMateriaView(claseId: clase.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TextoSeccion('Apuntes subidos'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: apuntes.isEmpty
                        ? EstadoVacio(
                            store.apuntesDe(clase.id).isEmpty
                                ? 'Aún no hay apuntes en esta clase. ¡Sé el primero en compartir!'
                                : 'No hay apuntes que coincidan con tu búsqueda',
                            icono: Icons.description_outlined)
                        : ListView.separated(
                            itemCount: apuntes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final a = apuntes[i];
                              return TarjetaApunte(
                                apunte: a,
                                onTap: () => mostrarAccionesApunte(context, a),
                                onDescargar: () => descargarApunte(context, a),
                              );
                            },
                          ),
                  ),
                  if (puedeSubir) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AgregarApunteView(claseId: clase.id),
                          ),
                        ),
                        child: const Text('Subir apuntes'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: const MenuInferior(),
        );
      },
    );
  }
}
