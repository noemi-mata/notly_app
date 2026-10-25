import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'navegacion.dart';

/// [soloMias] = true muestra las clases que creaste; false (solo para el
/// administrador general) muestra todas las clases de Notly.
class AdminClasesView extends StatefulWidget {
  const AdminClasesView({super.key, this.soloMias = true});

  final bool soloMias;

  @override
  State<AdminClasesView> createState() => _AdminClasesViewState();
}

class _AdminClasesViewState extends State<AdminClasesView> {
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
              final q = _buscar.text.trim().toLowerCase();
              final lista = (widget.soloMias ? store.clasesCreadas : store.clasesAdministrables)
                  .where((c) =>
                      q.isEmpty ||
                      c.nombre.toLowerCase().contains(q) ||
                      c.codigo.toLowerCase().contains(q))
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Encabezado(titulo: widget.soloMias ? 'Mis clases' : 'Todas las clases'),
                  const SizedBox(height: 16),
                  CampoBusqueda(
                    controller: _buscar,
                    hint: 'Buscar clase o código…',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: lista.isEmpty
                        ? EstadoVacio(widget.soloMias
                            ? 'Aún no has creado clases. Crea una desde Clases → Crear clase.'
                            : 'No hay clases para administrar')
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final c = lista[i];
                              return TarjetaBase(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        AvatarCuadrado(
                                            texto: c.iniciales, color: c.color),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(c.nombre,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Text(
                                                  'Código ${c.codigo} · ${store.alumnosDe(c).length} alumnos',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColores
                                                          .textoSuave)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => abrirClase(context, c),
                                          child: const Text('Ver clase'),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColores.error,
                                            side: const BorderSide(
                                                color: AppColores.error,
                                                width: 1.5),
                                          ),
                                          onPressed: () async {
                                            final ok = await confirmar(
                                              context,
                                              titulo: 'Eliminar clase',
                                              mensaje:
                                                  '¿Eliminar "${c.nombre}" con todos sus apuntes? No se puede deshacer.',
                                              textoAccion: 'Eliminar',
                                              peligro: true,
                                            );
                                            if (ok) store.eliminarClase(c.id);
                                          },
                                          child: const Text('Eliminar'),
                                        ),
                                      ],
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
      bottomNavigationBar: const MenuInferior(activa: Seccion.administrar),
    );
  }
}
