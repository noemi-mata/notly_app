import 'dart:convert' show latin1;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Crea archivos reales (PDF e imágenes) para los apuntes de ejemplo,
/// así se pueden ver, descargar y abrir igual que los que sube el usuario.
class MuestrasService {
  static const _cuerpo = [
    'Idea principal del tema y definiciones clave.',
    'Ejemplo 1: se resuelve paso a paso en el pizarrón.',
    'Recuerda revisar la fórmula antes del examen.',
    'Nota: preguntar al docente sobre el caso especial.',
    'Ejemplo 2: ejercicio de práctica con su resultado.',
    'Resumen: los tres puntos que más se repiten.',
    'Tarea: terminar los ejercicios de la página siguiente.',
    'Tip: relaciona este tema con la unidad anterior.',
    'Pendiente: comparar apuntes con los de un compañero.',
    'Conclusión y dudas para la siguiente clase.',
  ];

  static Future<Directory> _carpeta(String sub) async {
    final raiz = await getApplicationDocumentsDirectory();
    final dir = Directory('${raiz.path}/$sub');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Devuelve las rutas de los archivos creados (una por página en imágenes,
  /// una sola para un PDF).
  static Future<List<String>> crear({
    required String id,
    required String nombreArchivo,
    required String titulo,
    required String materia,
    required int paginas,
  }) async {
    final dir = await _carpeta('muestras/$id');
    final n = nombreArchivo.toLowerCase();
    if (n.endsWith('.pdf')) {
      final f = File('${dir.path}/$nombreArchivo');
      await f.writeAsBytes(_pdf(titulo, materia, paginas));
      return [f.path];
    }
    final rutas = <String>[];
    for (var i = 0; i < paginas; i++) {
      final f = File('${dir.path}/pagina_${i + 1}.png');
      await f.writeAsBytes(await _png(titulo, materia, i + 1, paginas));
      rutas.add(f.path);
    }
    return rutas;
  }

  // ------------------------------------------------------------------ PNG

  static Future<Uint8List> _png(
      String titulo, String materia, int pagina, int total) async {
    const w = 800.0;
    const h = 1100.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec, const Rect.fromLTWH(0, 0, w, h));
    c.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = Colors.white);

    final renglon = Paint()
      ..color = const Color(0xFFDCE6F5)
      ..strokeWidth = 2;
    for (var y = 200.0; y < h - 70; y += 52) {
      c.drawLine(Offset(60, y), Offset(w - 60, y), renglon);
    }
    c.drawLine(
        const Offset(110, 0),
        const Offset(110, h),
        Paint()
          ..color = const Color(0xFFF2B8B5)
          ..strokeWidth = 2);

    _texto(c, titulo, 130, 60, 40, const Color(0xFF17203A), bold: true);
    _texto(c, materia, 130, 120, 26, const Color(0xFF2456E5));
    for (var i = 0; i < 15; i++) {
      _texto(c, _cuerpo[(i + pagina) % _cuerpo.length], 130, 208 + i * 52.0,
          24, const Color(0xFF334155));
    }
    _texto(c, 'Página $pagina de $total', 130, h - 55, 22,
        const Color(0xFF64748B));

    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    final datos = await img.toByteData(format: ui.ImageByteFormat.png);
    return datos!.buffer.asUint8List();
  }

  static void _texto(Canvas c, String t, double x, double y, double size,
      Color color,
      {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 800 - 190);
    tp.paint(c, Offset(x, y));
  }

  // ------------------------------------------------------------------ PDF

  static String _limpio(String s) {
    final b = StringBuffer();
    for (final u in s.runes) {
      if (u == 0x28 || u == 0x29 || u == 0x5C) {
        b.write('\\');
        b.writeCharCode(u);
      } else if (u > 255) {
        b.write('?');
      } else {
        b.writeCharCode(u);
      }
    }
    return b.toString();
  }

  /// PDF mínimo escrito a mano (texto con Helvetica), una hoja por página.
  static Uint8List _pdf(String titulo, String materia, int paginas) {
    final total = paginas < 1 ? 1 : paginas;
    final objetos = <String>[];

    objetos.add('<< /Type /Catalog /Pages 2 0 R >>');
    final kids = [for (var i = 0; i < total; i++) '${4 + i * 2} 0 R'].join(' ');
    objetos.add('<< /Type /Pages /Kids [$kids] /Count $total >>');
    objetos.add(
        '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');

    for (var p = 0; p < total; p++) {
      final contenido = StringBuffer()
        ..writeln('BT /F1 22 Tf 60 780 Td (${_limpio(titulo)}) Tj ET')
        ..writeln('BT /F1 13 Tf 60 750 Td (${_limpio(materia)}) Tj ET');
      for (var i = 0; i < 14; i++) {
        final y = 700 - i * 38;
        contenido.writeln(
            'BT /F1 12 Tf 60 $y Td (${_limpio(_cuerpo[(i + p + 1) % _cuerpo.length])}) Tj ET');
      }
      contenido.writeln(
          'BT /F1 10 Tf 60 40 Td (${_limpio('Página ${p + 1} de $total')}) Tj ET');
      final texto = contenido.toString();
      final largo = latin1.encode(texto).length;

      objetos.add(
          '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents ${5 + p * 2} 0 R /Resources << /Font << /F1 3 0 R >> >> >>');
      objetos.add('<< /Length $largo >>\nstream\n${texto}endstream');
    }

    final out = BytesBuilder();
    void escribir(String s) => out.add(latin1.encode(s));

    escribir('%PDF-1.4\n');
    final posiciones = <int>[];
    for (var i = 0; i < objetos.length; i++) {
      posiciones.add(out.length);
      escribir('${i + 1} 0 obj\n${objetos[i]}\nendobj\n');
    }
    final xref = out.length;
    escribir('xref\n0 ${objetos.length + 1}\n');
    escribir('0000000000 65535 f \n');
    for (final p in posiciones) {
      escribir('${p.toString().padLeft(10, '0')} 00000 n \n');
    }
    escribir(
        'trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n');
    return out.toBytes();
  }
}
