import 'package:flutter/material.dart';

import '../modelos/apunte.dart';
import '../modelos/archivo_seleccionado.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/visor_archivo.dart';
import 'subir_apunte_view.dart';

class VistaPreviaView extends StatelessWidget {
  const VistaPreviaView({
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

  static const double limiteMb = 20;

  @override
  Widget build(BuildContext context) {
    final formatoOk = formatoValido(archivo.nombre);
    final tamanoOk = archivo.tamanoMb <= limiteMb;
    final todoOk = formatoOk && tamanoOk;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Vista previa'),
              const SizedBox(height: 12),
              const TextoSuave(
                  'Así verán tu apunte tus compañeros. Revísalo antes de subirlo.'),
              const SizedBox(height: 12),
              Expanded(
                child: VisorArchivo(
                  rutas: archivo.rutas,
                  nombre: archivo.nombre,
                  titulo: tema,
                  paginas: archivo.paginas,
                ),
              ),
              const SizedBox(height: 12),
              TarjetaArchivo(
                nombre: archivo.nombre,
                detalle:
                    '${archivo.paginas} pág. · ${archivo.tamanoMb.toStringAsFixed(1)} MB',
              ),
              const SizedBox(height: 10),
              _Validacion(
                ok: formatoOk,
                textoOk: 'Formato válido',
                textoError: 'Formato no permitido (usa PDF, JPG, PNG o DOCX)',
              ),
              const SizedBox(height: 4),
              _Validacion(
                ok: tamanoOk,
                textoOk: 'Tamaño dentro del límite de 20 MB',
                textoError: 'El archivo supera el límite de 20 MB',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cambiar archivo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: todoOk
                          ? () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => SubirApunteView(
                                    claseId: claseId,
                                    materiaId: materiaId,
                                    tema: tema,
                                    descripcion: descripcion,
                                    archivo: archivo,
                                  ),
                                ),
                              )
                          : null,
                      child: const Text('Subir'),
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

class _Validacion extends StatelessWidget {
  const _Validacion({
    required this.ok,
    required this.textoOk,
    required this.textoError,
  });

  final bool ok;
  final String textoOk;
  final String textoError;

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColores.exito : AppColores.error;
    return Row(
      children: [
        Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
            size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(ok ? textoOk : textoError,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }
}
