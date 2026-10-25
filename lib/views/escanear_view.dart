import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../modelos/archivo_seleccionado.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/visor_archivo.dart';

/// Toma fotos con la cámara (una por página) o las elige de la galería.
class EscanearView extends StatefulWidget {
  const EscanearView({super.key});

  @override
  State<EscanearView> createState() => _EscanearViewState();
}

class _EscanearViewState extends State<EscanearView> {
  final _picker = ImagePicker();
  final List<String> _fotos = [];
  final List<int> _tamanos = [];
  int _sel = 0;
  bool _ocupado = false;

  Future<void> _tomarFoto() async {
    if (_ocupado) return;
    setState(() => _ocupado = true);
    try {
      final foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      final tam = foto == null ? 0 : await foto.length();
      if (foto != null && mounted) {
        setState(() {
          _fotos.add(foto.path);
          _tamanos.add(tam);
          _sel = _fotos.length - 1;
        });
      }
    } catch (_) {
      if (mounted) {
        mostrarMensaje(context,
            'No se pudo abrir la cámara. Revisa los permisos de la app.');
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _galeria() async {
    try {
      final fotos = await _picker.pickMultiImage(imageQuality: 85);
      final tams = [for (final f in fotos) await f.length()];
      if (fotos.isNotEmpty && mounted) {
        setState(() {
          _fotos.addAll(fotos.map((f) => f.path));
          _tamanos.addAll(tams);
          _sel = _fotos.length - 1;
        });
      }
    } catch (_) {
      if (mounted) mostrarMensaje(context, 'No se pudo abrir la galería');
    }
  }

  void _quitar(int i) {
    setState(() {
      _fotos.removeAt(i);
      _tamanos.removeAt(i);
      if (_sel >= _fotos.length) _sel = _fotos.isEmpty ? 0 : _fotos.length - 1;
    });
  }

  void _listo() {
    final bytes = _tamanos.fold<int>(0, (a, b) => a + b);
    final ahora = DateTime.now();
    final ext = _fotos.first.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final hora = '${ahora.hour}${ahora.minute.toString().padLeft(2, '0')}';
    Navigator.of(context).pop(ArchivoSeleccionado(
      nombre: 'Escaneo-${ahora.day}-${ahora.month}-$hora.$ext',
      tamanoMb: bytes / 1048576,
      paginas: _fotos.length,
      rutas: List.of(_fotos),
    ));
  }

  Widget _marco() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF60A5FA), width: 3),
      ),
      child: _fotos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.document_scanner_outlined,
                        size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 12),
                    Text('Aquí verás tus fotos',
                        style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            )
          : InteractiveViewer(
              child: ImagenLocal(_fotos[_sel]),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _fotos.length;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Escanear apunte',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(child: _marco()),
              if (n > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: n,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setState(() => _sel = i),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50,
                            height: 64,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: i == _sel
                                    ? const Color(0xFF60A5FA)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ImagenLocal(_fotos[i], fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: () => _quitar(i),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                    color: AppColores.error,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                n == 0
                    ? 'Toma una foto de tu apunte o elige de la galería'
                    : '$n ${n == 1 ? 'página' : 'páginas'} · toca el botón azul para agregar otra',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFCBD5E1)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Galería',
                          icon: const Icon(Icons.photo_library_outlined,
                              color: Colors.white),
                          onPressed: _galeria,
                        ),
                        const Text('Galería',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _tomarFoto,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColores.primario,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _ocupado
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: Colors.white),
                                )
                              : const Icon(Icons.photo_camera,
                                  color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44)),
                      onPressed: n == 0 ? null : _listo,
                      child: const Text('Listo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
