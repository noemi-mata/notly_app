import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import '../widgets/visor_archivo.dart';
import 'acciones_apunte.dart';

/// Pantalla para ver un apunte (vista previa real) y actuar sobre él.
class ApunteView extends StatelessWidget {
  const ApunteView({super.key, required this.apunteId});

  final String apunteId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final a = store.apuntePorId(apunteId);

        if (a == null) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Encabezado(titulo: 'Apunte'),
                    Expanded(child: EstadoVacio('Este apunte ya no existe')),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: MenuInferior(),
          );
        }

        final clase = store.clasePorId(a.claseId);
        final materia = store.materiaPorId(a.materiaId)?.nombre ?? '';
        final fav = store.esFavorito(a);
        final puedeEliminar = a.autorId == store.usuarioActual?.id ||
            (clase != null && store.puedeAdministrar(clase));
        final fecha = '${a.fecha.day}/${a.fecha.month}/${a.fecha.year}';

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Encabezado(
                    titulo: a.tema,
                    tamano: 19,
                    acciones: [
                      IconButton(
                        tooltip: fav
                            ? 'Quitar de favoritos'
                            : 'Agregar a favoritos',
                        icon: Icon(fav ? Icons.star : Icons.star_border,
                            color: fav ? const Color(0xFFD99A00) : null),
                        onPressed: () => store.alternarFavorito(a),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Más opciones',
                        onSelected: (v) async {
                          final nav = Navigator.of(context);
                          if (v == 'reportar') {
                            await reportarApunte(context, a);
                          } else if (v == 'eliminar') {
                            final ok = await confirmar(
                              context,
                              titulo: 'Eliminar apunte',
                              mensaje:
                                  '¿Eliminar "${a.tema}"? No se puede deshacer.',
                              textoAccion: 'Eliminar',
                              peligro: true,
                            );
                            if (ok) {
                              store.eliminarApunte(a.id);
                              nav.pop();
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'reportar',
                            child: Row(children: [
                              Icon(Icons.flag_outlined),
                              SizedBox(width: 12),
                              Text('Reportar'),
                            ]),
                          ),
                          if (puedeEliminar)
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(children: [
                                Icon(Icons.delete_outline,
                                    color: AppColores.error),
                                SizedBox(width: 12),
                                Text('Eliminar apunte',
                                    style: TextStyle(color: AppColores.error)),
                              ]),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$materia · Subido por ${store.nombreAutor(a.autorId)} · $fecha',
                    style: const TextStyle(
                        fontSize: 13, color: AppColores.textoSuave),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: VisorArchivo(
                      rutas: a.rutas,
                      nombre: a.nombreArchivo,
                      titulo: a.tema,
                      paginas: a.paginas,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => descargarApunte(context, a),
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Descargar'),
                    ),
                  ),
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
