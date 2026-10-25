import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/archivos_service.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import '../widgets/visor_archivo.dart';

class ApunteDescargadoView extends StatelessWidget {
  const ApunteDescargadoView({super.key, required this.apunteId});

  final String apunteId;

  /// Abre el apunte dentro de la app (PDF, imágenes) usando la copia descargada.
  void _abrir(BuildContext context, List<String> rutas) {
    final apunte = AppStore.instance.apuntePorId(apunteId);
    if (apunte == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LectorApunteView(
          titulo: apunte.tema,
          nombre: apunte.nombreArchivo,
          rutas: rutas.isNotEmpty ? rutas : apunte.rutas,
          paginas: apunte.paginas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final apunte = store.apuntePorId(apunteId);
    final rutas = store.rutasDescargadas(apunteId);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    color: AppColores.exito, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 24),
              const Text('¡Apunte descargado!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const TextoSuave(
                  'Se guardó en tu dispositivo y en la pestaña Descargas de Notly.',
                  centrado: true),
              const SizedBox(height: 20),
              if (apunte != null)
                TarjetaArchivo(
                  nombre: apunte.nombreArchivo,
                  detalle: 'Toca para abrirlo',
                  onTap: () => _abrir(context, rutas),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _abrir(context, rutas),
                  child: const Text('Abrir apunte'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: apunte == null
                      ? null
                      : () async {
                          final error =
                              await ArchivosService.guardarEnDispositivo(
                                  apunte.nombreArchivo, apunte.rutas);
                          if (context.mounted) {
                            mostrarMensaje(context,
                                error ?? 'Apunte guardado en tu dispositivo');
                          }
                        },
                  child: const Text('Guardar en mi dispositivo'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: () {
                    seccionActual.value = Seccion.clases;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: const Text('Volver al inicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LectorApunteView extends StatelessWidget {
  const _LectorApunteView({
    required this.titulo,
    required this.nombre,
    required this.rutas,
    required this.paginas,
  });

  final String titulo;
  final String nombre;
  final List<String> rutas;
  final int paginas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              Encabezado(titulo: titulo, tamano: 19),
              const SizedBox(height: 12),
              Expanded(
                child: VisorArchivo(
                  rutas: rutas,
                  nombre: nombre,
                  titulo: titulo,
                  paginas: paginas,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }
}
