import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/solicitud.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';

/// Solicitudes para entrar a las clases privadas que administras.
class AdminSolicitudesView extends StatelessWidget {
  const AdminSolicitudesView({super.key});

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
              final lista = store.solicitudesPorResponder;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(titulo: 'Solicitudes'),
                  const SizedBox(height: 12),
                  TextoSeccion('Pendientes (${lista.length})'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: lista.isEmpty
                        ? const EstadoVacio(
                            'No hay solicitudes pendientes en tus clases',
                            icono: Icons.how_to_reg_outlined)
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                TarjetaSolicitud(solicitud: lista[i]),
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

/// Tarjeta con los botones Aprobar / Rechazar.
class TarjetaSolicitud extends StatelessWidget {
  const TarjetaSolicitud({super.key, required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final u = store.usuarioPorId(solicitud.usuarioId);
    final c = store.clasePorId(solicitud.claseId);
    final f = solicitud.fecha;
    return TarjetaBase(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCuadrado(
                    texto: u?.iniciales ?? '?', color: AppColores.primario),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u?.nombre ?? 'Usuario',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Quiere entrar a ${c?.nombre ?? 'la clase'}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColores.textoSuave)),
                      Text('${f.day}/${f.month}/${f.year}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColores.textoSuave)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: AppColores.exito),
                    onPressed: () {
                      store.responderSolicitud(solicitud, aprobar: true);
                      mostrarMensaje(
                          context, '${u?.nombre ?? 'Usuario'} ya está en la clase');
                    },
                    child: const Text('Aprobar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColores.error,
                      side: const BorderSide(
                          color: AppColores.error, width: 1.5),
                    ),
                    onPressed: () {
                      store.responderSolicitud(solicitud, aprobar: false);
                      mostrarMensaje(context, 'Solicitud rechazada');
                    },
                    child: const Text('Rechazar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
