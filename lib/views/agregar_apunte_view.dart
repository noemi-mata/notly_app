import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/archivo_seleccionado.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'agregar_materia_view.dart';
import 'escanear_view.dart';
import 'selector_archivos.dart';
import 'vista_previa_view.dart';

class AgregarApunteView extends StatefulWidget {
  const AgregarApunteView({super.key, required this.claseId});

  final String claseId;

  @override
  State<AgregarApunteView> createState() => _AgregarApunteViewState();
}

class _AgregarApunteViewState extends State<AgregarApunteView> {
  final _tema = TextEditingController();
  final _desc = TextEditingController();
  String? _materiaId;
  ArchivoSeleccionado? _archivo;

  @override
  void dispose() {
    _tema.dispose();
    _desc.dispose();
    super.dispose();
  }

  bool get _completo =>
      _materiaId != null && _tema.text.trim().isNotEmpty && _archivo != null;

  Future<void> _escanear() async {
    final r = await Navigator.of(context).push<ArchivoSeleccionado>(
      MaterialPageRoute(builder: (_) => const EscanearView()),
    );
    if (r != null) setState(() => _archivo = r);
  }

  Future<void> _elegir() async {
    final r = await elegirArchivo(context);
    if (r != null) setState(() => _archivo = r);
  }

  Future<void> _nuevaMateria() async {
    final nombre = await Navigator.of(context).push<String>(
      MaterialPageRoute(
          builder: (_) => AgregarMateriaView(claseId: widget.claseId)),
    );
    if (nombre == null) return;
    final m = AppStore.instance
        .materiasDe(widget.claseId)
        .where((x) => x.nombre == nombre)
        .firstOrNull;
    setState(() => _materiaId = m?.id);
  }

  void _continuar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VistaPreviaView(
          claseId: widget.claseId,
          materiaId: _materiaId!,
          tema: _tema.text.trim(),
          descripcion: _desc.text.trim(),
          archivo: _archivo!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materias = AppStore.instance.materiasDe(widget.claseId);
    final clase = AppStore.instance.clasePorId(widget.claseId);
    final puedeCrearMateria =
        clase != null && AppStore.instance.puedeAdministrar(clase);
    final a = _archivo;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Agregar apunte'),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextoSeccion('Materia o unidad'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _materiaId,
                        hint: const Text('Elige una materia o unidad'),
                        items: [
                          for (final m in materias)
                            DropdownMenuItem(value: m.id, child: Text(m.nombre)),
                        ],
                        onChanged: (v) => setState(() => _materiaId = v),
                      ),
                      // Solo el docente o administrador de la clase crea materias
                      // y unidades; el alumno elige una de las existentes.
                      if (puedeCrearMateria)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _nuevaMateria,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar materia o unidad'),
                          ),
                        )
                      else if (materias.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: TextoSuave(
                              'Esta clase aún no tiene materias ni unidades. Pide a tu docente que las agregue.'),
                        ),
                      const SizedBox(height: 4),
                      CampoTexto(
                        etiqueta: 'Tema del apunte',
                        controller: _tema,
                        hint: 'Ej. Álgebra - Tema 3',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      CampoTexto(
                        etiqueta: 'Descripción (opcional)',
                        controller: _desc,
                        hint: 'Ej. Ejercicios del pizarrón',
                      ),
                      const SizedBox(height: 20),
                      const TextoSeccion('¿Cómo quieres agregarlo?'),
                      const SizedBox(height: 8),
                      TarjetaOpcion(
                        icono: Icons.photo_camera_outlined,
                        color: AppColores.primario,
                        titulo: 'Escanear con la cámara',
                        subtitulo: 'Toma fotos o elige imágenes de tu galería',
                        onTap: _escanear,
                      ),
                      const SizedBox(height: 10),
                      TarjetaOpcion(
                        icono: Icons.insert_drive_file_outlined,
                        color: AppColores.terracota,
                        titulo: 'Elegir archivo del teléfono',
                        subtitulo: 'PDF, JPG, PNG o DOCX · máx. 20 MB',
                        onTap: _elegir,
                      ),
                      if (a != null) ...[
                        const SizedBox(height: 16),
                        const TextoSeccion('Archivo seleccionado'),
                        const SizedBox(height: 8),
                        TarjetaArchivo(
                          nombre: a.nombre,
                          detalle:
                              '${a.paginas} pág. · ${a.tamanoMb.toStringAsFixed(1)} MB',
                          trailing: IconButton(
                            tooltip: 'Quitar archivo',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _archivo = null),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _completo ? _continuar : null,
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
