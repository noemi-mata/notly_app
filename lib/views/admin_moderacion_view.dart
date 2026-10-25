import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/apunte.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'revisar_reporte_view.dart';

class AdminModeracionView extends StatelessWidget {
  const AdminModeracionView({super.key});

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
              final lista = store.reportesModerables;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(titulo: 'Moderación'),
                  const SizedBox(height: 12),
                  TextoSeccion('Reportados (${lista.length})'),
                  const SizedBox(height: 10),
                  Expanded(
                    child: lista.isEmpty
                        ? const EstadoVacio('No hay apuntes reportados',
                            icono: Icons.verified_user_outlined)
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final r = lista[i];
                              final a = store.apuntePorId(r.apunteId)!;
                              final quien =
                                  store.usuarioPorId(r.reportanteId)?.nombre ?? '—';
                              return TarjetaBase(
                                child: Row(
                                  children: [
                                    AvatarCuadrado(
                                        texto: a.tipo.etiqueta,
                                        color: a.tipo.color,
                                        tamano: 40),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(a.tema,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                          Text('Motivo: ${r.motivo}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColores.error)),
                                          Text('Reportado por $quien',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColores.textoSuave)),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => RevisarReporteView(
                                              reporteId: r.id),
                                        ),
                                      ),
                                      child: const Text('Revisar'),
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
