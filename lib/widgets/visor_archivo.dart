import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart' show PdfViewer;

import '../data/archivos_service.dart';
import 'app_tema.dart';
import 'componentes.dart';

/// Imagen desde una ruta del teléfono (en web la ruta es una dirección blob).
class ImagenLocal extends StatelessWidget {
  const ImagenLocal(this.ruta, {super.key, this.fit = BoxFit.contain});

  final String ruta;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget error(BuildContext c, Object e, StackTrace? st) => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: TextoSuave('No se pudo mostrar esta imagen',
                centrado: true),
          ),
        );
    return kIsWeb
        ? Image.network(ruta, fit: fit, errorBuilder: error)
        : Image.file(File(ruta), fit: fit, errorBuilder: error);
  }
}

/// Muestra el contenido real de un apunte:
/// - PDF: visor con zoom y desplazamiento.
/// - Imágenes (fotos escaneadas): páginas deslizables con zoom.
/// - DOCX: no se puede mostrar dentro de la app; ofrece abrirlo con otra app.
/// - Sin archivo (apuntes de ejemplo): una hoja de muestra.
class VisorArchivo extends StatelessWidget {
  const VisorArchivo({
    super.key,
    required this.rutas,
    required this.nombre,
    required this.titulo,
    required this.paginas,
  });

  final List<String> rutas;
  final String nombre;
  final String titulo;
  final int paginas;

  @override
  Widget build(BuildContext context) {
    final hayArchivo = rutas.isNotEmpty && ArchivosService.existe(rutas.first);
    final n = nombre.toLowerCase();

    final Widget contenido;
    if (!hayArchivo) {
      contenido = _SinArchivo(titulo: titulo, paginas: paginas);
    } else if (n.endsWith('.pdf')) {
      contenido = kIsWeb
          ? PdfViewer.uri(Uri.parse(rutas.first))
          : PdfViewer.file(rutas.first);
    } else if (n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png')) {
      contenido = _VisorImagenes(rutas: rutas);
    } else {
      contenido = _SinVistaPrevia(nombre: nombre, ruta: rutas.first);
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: contenido,
    );
  }
}

class _VisorImagenes extends StatefulWidget {
  const _VisorImagenes({required this.rutas});

  final List<String> rutas;

  @override
  State<_VisorImagenes> createState() => _VisorImagenesState();
}

class _VisorImagenesState extends State<_VisorImagenes> {
  final _controller = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.rutas.length;
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: total,
          onPageChanged: (i) => setState(() => _pagina = i),
          itemBuilder: (context, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: ImagenLocal(widget.rutas[i]),
            ),
          ),
        ),
        if (total > 1)
          Positioned(
            right: 12,
            bottom: 10,
            child: Insignia('Página ${_pagina + 1} de $total'),
          ),
      ],
    );
  }
}

class _SinVistaPrevia extends StatelessWidget {
  const _SinVistaPrevia({required this.nombre, required this.ruta});

  final String nombre;
  final String ruta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                size: 48, color: AppColores.primario),
            const SizedBox(height: 12),
            Text(nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const TextoSuave(
                'Los archivos de Word no se pueden mostrar dentro de la app.',
                centrado: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final error = await ArchivosService.abrir(ruta);
                if (error != null && context.mounted) {
                  mostrarMensaje(context, error);
                }
              },
              child: const Text('Abrir con otra app'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SinArchivo extends StatelessWidget {
  const _SinArchivo({required this.titulo, required this.paginas});

  final String titulo;
  final int paginas;

  @override
  Widget build(BuildContext context) {
    const anchos = [0.92, 0.78, 0.88, 0.60, 0.95, 0.70, 0.85];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColores.texto)),
          const SizedBox(height: 12),
          for (final a in anchos)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: a,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const TextoSuave(
              'Apunte de ejemplo: no tiene un archivo guardado. Los apuntes que subas sí se podrán ver aquí.'),
        ],
      ),
    );
  }
}
