import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';
import '../modelos/solicitud.dart';
import '../modelos/usuario.dart';
import '../widgets/app_tema.dart';
import 'admin_solicitudes_view.dart';
import 'clases_ocultas_view.dart';
import 'crear_clase_view.dart';
import 'navegacion.dart';
import 'unirse_clase_view.dart';

class InicioTab extends StatefulWidget {
  const InicioTab({super.key});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  final _buscar = TextEditingController();

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

  void _ir(Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final q = _buscar.text.trim().toLowerCase();
        final clases = store.clasesVisibles
            .where((c) => c.nombre.toLowerCase().contains(q))
            .toList();
        final ocultas = store.clasesOcultas.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloPagina(switch (store.modo) {
              ModoUsuario.alumno => 'Mis clases',
              ModoUsuario.docente => 'Mis clases creadas',
              ModoUsuario.administrador => 'Todas las clases',
            }),
            const SizedBox(height: 16),
            CampoBusqueda(
              controller: _buscar,
              hint: 'Buscar clase…',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (store.puedeCrearClases)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _ir(const CrearClaseView()),
                  icon: const Icon(Icons.add),
                  label: const Text('Crear clase'),
                ),
              )
            else if (store.modo == ModoUsuario.alumno)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _ir(const UnirseClaseView()),
                  child: const Text('Unirme a una clase'),
                ),
              ),
            if (store.gestionaClases &&
                store.solicitudesPorResponder.isNotEmpty) ...[
              const SizedBox(height: 12),
              _Banner(
                icono: Icons.how_to_reg_outlined,
                color: AppColores.morado,
                texto:
                    '${store.solicitudesPorResponder.length} solicitud(es) para entrar a tus clases',
                accion: 'Revisar',
                onTap: () => _ir(const AdminSolicitudesView()),
              ),
            ],
            if (!store.gestionaClases)
              for (final s in store.misSolicitudesAbiertas) ...[
              const SizedBox(height: 12),
              _Banner(
                icono: s.estado == EstadoSolicitud.pendiente
                    ? Icons.hourglass_top
                    : Icons.block,
                color: s.estado == EstadoSolicitud.pendiente
                    ? AppColores.primario
                    : AppColores.error,
                texto: s.estado == EstadoSolicitud.pendiente
                    ? 'Solicitud pendiente: ${store.clasePorId(s.claseId)?.nombre}'
                    : 'Rechazaron tu solicitud a ${store.clasePorId(s.claseId)?.nombre}',
                accion: s.estado == EstadoSolicitud.pendiente ? null : 'Quitar',
                onTap: () => store.descartarSolicitud(s),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: TextoSeccion(store.gestionaClases
                        ? (store.modoAdministrador ? 'Clases de Notly' : 'Clases que creaste')
                        : 'Clases en las que estás')),
                OutlinedButton(
                  onPressed: () => _ir(const ClasesOcultasView()),
                  child: Text('Clases ocultas ($ocultas)'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: clases.isEmpty
                  ? EstadoVacio(
                      store.modoAdministrador
                          ? 'Todavía no hay clases en Notly.'
                          : store.gestionaClases
                          ? 'Aún no has creado clases. Toca "Crear clase".'
                          : 'No tienes clases todavía. Únete con el código que te dé tu docente.',
                      icono: Icons.menu_book_outlined)
                  : ListView.separated(
                      itemCount: clases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final c = clases[i];
                        return TarjetaClase(
                          clase: c,
                          onTap: () => abrirClase(context, c),
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Más opciones',
                            icon: const Icon(Icons.more_vert),
                            onSelected: (_) {
                              store.ocultar(c);
                              mostrarMensaje(
                                context,
                                'Clase oculta',
                                accion: 'Deshacer',
                                alAccion: () => store.mostrar(c),
                              );
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'ocultar',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility_off_outlined),
                                    SizedBox(width: 12),
                                    Text('Ocultar clase'),
                                  ],
                                ),
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
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icono,
    required this.color,
    required this.texto,
    required this.onTap,
    this.accion,
  });

  final IconData icono;
  final Color color;
  final String texto;
  final String? accion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icono, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
          if (accion != null)
            TextButton(onPressed: onTap, child: Text(accion!)),
        ],
      ),
    );
  }
}
