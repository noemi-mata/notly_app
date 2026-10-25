import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/reporte.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import '../widgets/visor_archivo.dart';

class RevisarReporteView extends StatelessWidget {
  const RevisarReporteView({super.key, required this.reporteId});

  final String reporteId;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final r = store.reportes.where((x) => x.id == reporteId).firstOrNull;
    final a = r == null ? null : store.apuntePorId(r.apunteId);

    if (r == null || a == null || r.estado != EstadoReporte.pendiente) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Encabezado(titulo: 'Revisar reporte'),
                Expanded(child: EstadoVacio('Este reporte ya fue resuelto')),
              ],
            ),
          ),
        ),
        bottomNavigationBar: MenuInferior(activa: Seccion.administrar),
      );
    }

    final autor = store.usuarioPorId(a.autorId);
    final reportante = store.usuarioPorId(r.reportanteId);
    final clase = store.clasePorId(a.claseId);
    final materia = store.materiaPorId(a.materiaId)?.nombre ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Revisar reporte'),
              const SizedBox(height: 16),
              Expanded(
                child: VisorArchivo(
                  rutas: a.rutas,
                  nombre: a.nombreArchivo,
                  titulo: a.tema,
                  paginas: a.paginas,
                ),
              ),
              const SizedBox(height: 12),
              TarjetaBase(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subido por ${autor?.nombre ?? '—'}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      Text('$materia · ${clase?.nombre ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColores.textoSuave)),
                      const SizedBox(height: 8),
                      Text('Motivo: ${r.motivo}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColores.error)),
                      Text('Reportado por ${reportante?.nombre ?? '—'}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColores.textoSuave)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    mostrarMensaje(context, 'Apunte conservado');
                    store.conservarApunte(r);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Conservar apunte'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColores.error),
                  onPressed: () async {
                    final ok = await confirmar(
                      context,
                      titulo: 'Eliminar apunte',
                      mensaje: '¿Eliminar "${a.tema}"?',
                      textoAccion: 'Eliminar',
                      peligro: true,
                    );
                    if (!ok || !context.mounted) return;
                    final nav = Navigator.of(context);
                    store.eliminarPorReporte(r);
                    nav.pop();
                  },
                  child: const Text('Eliminar apunte'),
                ),
              ),
              if (autor != null && !autor.esAdministrador) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      foregroundColor: AppColores.texto,
                      side: const BorderSide(
                          color: AppColores.borde, width: 1.5),
                    ),
                    onPressed: () async {
                      final ok = await confirmar(
                        context,
                        titulo: 'Suspender usuario',
                        mensaje:
                            '¿Eliminar el apunte y suspender a ${autor.nombre}?',
                        textoAccion: 'Suspender',
                        peligro: true,
                      );
                      if (!ok || !context.mounted) return;
                      final nav = Navigator.of(context);
                      store.eliminarPorReporte(r, suspenderAutor: true);
                      nav.pop();
                    },
                    child: const Text('Suspender a quien lo subió'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(activa: Seccion.administrar),
    );
  }
}
