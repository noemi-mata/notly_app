import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/archivo_seleccionado.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'apunte_subido_view.dart';

class SubirApunteView extends StatefulWidget {
  const SubirApunteView({
    super.key,
    required this.claseId,
    required this.materiaId,
    required this.tema,
    required this.descripcion,
    required this.archivo,
  });

  final String claseId;
  final String materiaId;
  final String tema;
  final String descripcion;
  final ArchivoSeleccionado archivo;

  @override
  State<SubirApunteView> createState() => _SubirApunteViewState();
}

class _SubirApunteViewState extends State<SubirApunteView> {
  Timer? _timer;
  double _progreso = 0;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciar() {
    setState(() {
      _progreso = 0;
      _error = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (t) {
      if (!mounted) return;
      setState(() => _progreso = (_progreso + 0.1).clamp(0.0, 1.0));
      if (_progreso >= 1) {
        t.cancel();
        _terminar();
      }
    });
  }

  Future<void> _terminar() async {
    try {
      final a = await AppStore.instance.subirApunte(
        claseId: widget.claseId,
        materiaId: widget.materiaId,
        tema: widget.tema,
        descripcion: widget.descripcion,
        nombreArchivo: widget.archivo.nombre,
        tamanoMb: widget.archivo.tamanoMb,
        paginas: widget.archivo.paginas,
        rutas: widget.archivo.rutas,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ApunteSubidoView(apunteId: a.id)),
      );
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final materia = store.materiaPorId(widget.materiaId)?.nombre ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Subir apunte'),
              const SizedBox(height: 20),
              CampoTexto(
                  etiqueta: 'Materia',
                  controller: TextEditingController(text: materia),
                  enabled: false),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Tema del apunte',
                  controller: TextEditingController(text: widget.tema),
                  enabled: false),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Autor',
                  controller: TextEditingController(
                      text: store.usuarioActual?.nombre ?? ''),
                  enabled: false),
              const SizedBox(height: 16),
              TarjetaArchivo(
                nombre: widget.archivo.nombre,
                detalle:
                    '${widget.archivo.paginas} pág. · ${widget.archivo.tamanoMb.toStringAsFixed(1)} MB',
              ),
              const SizedBox(height: 20),
              if (_error) ...[
                const MensajeError('No se pudo subir, inténtalo de nuevo'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _iniciar, child: const Text('Reintentar')),
                ),
              ] else ...[
                const Text('Subiendo apunte…',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: _progreso,
                    minHeight: 10,
                    color: AppColores.primario,
                    backgroundColor: const Color(0xFFE2DCCF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
