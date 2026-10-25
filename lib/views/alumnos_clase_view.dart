import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';

/// Lista de las personas inscritas en una clase.
/// El administrador de la clase puede sacar a un alumno.
class AlumnosClaseView extends StatefulWidget {
  const AlumnosClaseView({super.key, required this.claseId});

  final String claseId;

  @override
  State<AlumnosClaseView> createState() => _AlumnosClaseViewState();
}

class _AlumnosClaseViewState extends State<AlumnosClaseView> {
  final _buscar = TextEditingController();

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: ListenableBuilder(
            listenable: AppStore.instance,
            builder: (context, _) {
              final store = AppStore.instance;
              final clase = store.clasePorId(widget.claseId);
              if (clase == null) {
                return const Column(
                  children: [
                    Encabezado(titulo: 'Alumnos'),
                    Expanded(child: EstadoVacio('Esta clase ya no existe')),
                  ],
                );
              }
              final q = _buscar.text.trim().toLowerCase();
              final admin = store.puedeAdministrar(clase);
              if (!admin) {
                return const Column(
                  children: [
                    Encabezado(titulo: 'Alumnos inscritos'),
                    Expanded(
                        child: EstadoVacio(
                            'Solo el docente o administrador de la clase puede ver a los alumnos inscritos',
                            icono: Icons.lock_outline)),
                  ],
                );
              }
              // El creador (docente) va primero, luego los demás por nombre.
              final todos = store.alumnosDe(clase);
              final personas = todos
                  .where((u) => q.isEmpty || u.nombre.toLowerCase().contains(q))
                  .toList()
                ..sort((a, b) => a.nombre.compareTo(b.nombre));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(titulo: 'Alumnos inscritos'),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                        '${clase.nombre} · ${todos.length} alumnos',
                        style: const TextStyle(
                            fontSize: 13, color: AppColores.textoSuave)),
                  ),
                  const SizedBox(height: 12),
                  CampoBusqueda(
                    controller: _buscar,
                    hint: 'Buscar por nombre…',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: personas.isEmpty
                        ? EstadoVacio(
                            todos.isEmpty
                                ? 'Aún no hay alumnos inscritos en esta clase'
                                : 'No hay alumnos con ese nombre',
                            icono: Icons.people_outline)
                        : ListView.separated(
                            itemCount: personas.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final u = personas[i];
                              final subidos = store
                                  .apuntesDe(clase.id)
                                  .where((a) => a.autorId == u.id)
                                  .length;
                              final soyYo = u.id == store.usuarioActual?.id;
                              return TarjetaBase(
                                child: Row(
                                  children: [
                                    AvatarCuadrado(
                                        texto: u.iniciales,
                                        color: AppColores.primario),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                    soyYo
                                                        ? '${u.nombre} (tú)'
                                                        : u.nombre,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700)),
                                              ),
                                            ],
                                          ),
                                          Text(
                                              'Alumno · $subidos apuntes',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColores.textoSuave)),
                                        ],
                                      ),
                                    ),
                                    if (admin)
                                      IconButton(
                                        tooltip: 'Sacar de la clase',
                                        icon: const Icon(
                                            Icons.person_remove_outlined,
                                            color: AppColores.error),
                                        onPressed: () async {
                                          final ok = await confirmar(
                                            context,
                                            titulo: 'Sacar de la clase',
                                            mensaje:
                                                '¿Sacar a ${u.nombre} de "${clase.nombre}"? Sus apuntes se conservan.',
                                            textoAccion: 'Sacar',
                                            peligro: true,
                                          );
                                          if (ok) store.sacarDeClase(clase, u);
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }
}
