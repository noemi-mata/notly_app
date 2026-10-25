import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart' show PdfDocument;

/// Todo lo que toca archivos reales del teléfono:
/// copiar, borrar, abrir con otra app y contar páginas de un PDF.
class ArchivosService {
  static Future<Directory> _carpeta(String sub) async {
    final raiz = await getApplicationDocumentsDirectory();
    final dir = Directory('${raiz.path}/$sub');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static String nombreDe(String ruta) => ruta.split(RegExp(r'[\\/]')).last;

  static bool existe(String ruta) => kIsWeb ? true : File(ruta).existsSync();

  /// Copia los archivos a una carpeta permanente de la app (los que entrega
  /// el selector o la cámara viven en la caché y el sistema los puede borrar).
  static Future<List<String>> copiar(List<String> origenes, String sub) async {
    if (kIsWeb) return List.of(origenes); // en web no hay carpeta del teléfono
    final dir = await _carpeta(sub);
    final nuevas = <String>[];
    for (var i = 0; i < origenes.length; i++) {
      final destino = '${dir.path}/${i}_${nombreDe(origenes[i])}';
      await File(origenes[i]).copy(destino);
      nuevas.add(destino);
    }
    return nuevas;
  }

  static Future<void> borrarCarpeta(String sub) async {
    if (kIsWeb) return;
    try {
      final raiz = await getApplicationDocumentsDirectory();
      final dir = Directory('${raiz.path}/$sub');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  static Future<int> paginasPdf(String ruta) async {
    try {
      final doc = await PdfDocument.openFile(ruta);
      final n = doc.pages.length;
      doc.dispose();
      return n < 1 ? 1 : n;
    } catch (_) {
      return 1;
    }
  }

  /// Abre el archivo con la app del teléfono que corresponda (Word, galería…).
  /// Devuelve un mensaje de error, o null si todo salió bien.
  static Future<String?> abrir(String ruta) async {
    if (kIsWeb) return 'Abrir con otra app solo está disponible en el teléfono';
    try {
      final r = await OpenFilex.open(ruta);
      if (r.type == ResultType.done) return null;
      if (r.type == ResultType.noAppToOpen) {
        return 'No hay una app instalada para abrir este tipo de archivo';
      }
      return 'No se pudo abrir el archivo';
    } catch (_) {
      return 'No se pudo abrir el archivo';
    }
  }

  static String _mime(String ext) => switch (ext.toLowerCase()) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        _ => 'application/octet-stream',
      };

  /// Guarda de verdad el archivo en el dispositivo.
  /// - Navegador: lo descarga (carpeta Descargas del navegador).
  /// - Teléfono: abre el selector de carpeta del sistema (p. ej. Descargas).
  /// Devuelve null si se guardó, o un mensaje si no se pudo.
  static Future<String?> guardarEnDispositivo(
      String nombre, List<String> rutas) async {
    if (rutas.isEmpty) {
      return 'Este apunte de ejemplo no tiene archivo para guardar';
    }
    try {
      for (var i = 0; i < rutas.length; i++) {
        final bytes = await XFile(rutas[i]).readAsBytes();
        final punto = nombre.lastIndexOf('.');
        final base = punto > 0 ? nombre.substring(0, punto) : nombre;
        final ext = punto > 0 ? nombre.substring(punto + 1) : '';
        final sufijo = rutas.length > 1 ? '_pagina_${i + 1}' : '';

        if (kIsWeb) {
          await FileSaver.instance.saveFile(
            name: '$base$sufijo',
            bytes: bytes,
            fileExtension: ext,
            mimeType: MimeType.custom,
            customMimeType: _mime(ext),
          );
        } else {
          final destino = await FilePicker.platform.saveFile(
            dialogTitle: 'Guardar apunte',
            fileName: ext.isEmpty ? '$base$sufijo' : '$base$sufijo.$ext',
            bytes: bytes,
          );
          if (destino == null) return 'No se guardó en el dispositivo';
        }
      }
      return null;
    } catch (e) {
      return 'No se pudo guardar el archivo: $e';
    }
  }
}
