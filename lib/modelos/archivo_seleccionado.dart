/// Archivo (o fotos) elegido antes de subirlo.
class ArchivoSeleccionado {
  const ArchivoSeleccionado({
    required this.nombre,
    required this.tamanoMb,
    required this.paginas,
    this.rutas = const [],
  });

  final String nombre;
  final double tamanoMb;
  final int paginas;

  /// Rutas reales en el teléfono. Una sola para PDF/DOCX; una por foto
  /// cuando se escanea con la cámara.
  final List<String> rutas;
}
