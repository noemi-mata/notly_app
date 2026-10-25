import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';

/// Agrega una materia o una unidad. Devuelve (pop) el nombre creado.
class AgregarMateriaView extends StatefulWidget {
  const AgregarMateriaView({super.key, required this.claseId});

  final String claseId;

  @override
  State<AgregarMateriaView> createState() => _AgregarMateriaViewState();
}

class _AgregarMateriaViewState extends State<AgregarMateriaView> {
  final _nombre = TextEditingController();
  bool _unidad = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombre.text.trim();
    final e = AppStore.instance
        .agregarMateria(widget.claseId, nombre, esUnidad: _unidad);
    if (e != null) {
      setState(() => _error = e);
      return;
    }
    Navigator.of(context).pop(nombre);
  }

  @override
  Widget build(BuildContext context) {
    final clase = AppStore.instance.clasePorId(widget.claseId);
    final tipo = _unidad ? 'unidad' : 'materia';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Agregar materia o unidad'),
              const SizedBox(height: 12),
              TextoSuave('Se agregará a ${clase?.nombre ?? 'la clase'}.'),
              const SizedBox(height: 16),
              const TextoSeccion('¿Qué vas a agregar?'),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        icon: Icon(Icons.menu_book_outlined),
                        label: Text('Materia')),
                    ButtonSegment(
                        value: true,
                        icon: Icon(Icons.folder_outlined),
                        label: Text('Unidad')),
                  ],
                  selected: {_unidad},
                  onSelectionChanged: (s) =>
                      setState(() => _unidad = s.first),
                ),
              ),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Nombre de la $tipo',
                  controller: _nombre,
                  hint: _unidad ? 'Ej. Unidad 1' : 'Ej. Programación Móvil'),
              if (_error != null) ...[
                const SizedBox(height: 16),
                MensajeError(_error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _guardar,
                    child: Text('Guardar $tipo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
