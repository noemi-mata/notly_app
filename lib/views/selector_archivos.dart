import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../data/archivos_service.dart';
import '../modelos/archivo_seleccionado.dart';
import '../widgets/componentes.dart';

/// Abre el explorador de archivos del teléfono (PDF, JPG, PNG o DOCX).
Future<ArchivoSeleccionado?> elegirArchivo(BuildContext context) async {
  try {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'docx'],
      withData: kIsWeb, // en web no hay ruta de archivo: se usan los bytes
    );
    if (r == null || r.files.isEmpty) return null; // canceló

    final f = r.files.single;
    String? ruta;
    if (kIsWeb) {
      final bytes = f.bytes;
      if (bytes != null) {
        final n = f.name.toLowerCase();
        final mime = n.endsWith('.pdf')
            ? 'application/pdf'
            : n.endsWith('.png')
                ? 'image/png'
                : (n.endsWith('.jpg') || n.endsWith('.jpeg'))
                    ? 'image/jpeg'
                    : 'application/octet-stream';
        // En web el XFile crea una dirección (blob) que el visor puede abrir.
        ruta = XFile.fromData(bytes, name: f.name, mimeType: mime).path;
      }
    } else {
      ruta = f.path;
    }
    if (ruta == null) {
      if (context.mounted) {
        mostrarMensaje(context, 'No se pudo leer el archivo elegido');
      }
      return null;
    }

    final esPdf = f.name.toLowerCase().endsWith('.pdf');
    return ArchivoSeleccionado(
      nombre: f.name,
      tamanoMb: f.size / 1048576,
      paginas: esPdf && !kIsWeb ? await ArchivosService.paginasPdf(ruta) : 1,
      rutas: [ruta],
    );
  } catch (_) {
    if (context.mounted) {
      mostrarMensaje(context, 'No se pudo abrir el selector de archivos');
    }
    return null;
  }
}
