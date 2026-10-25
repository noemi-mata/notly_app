import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'navegacion.dart';

class CrearClaseView extends StatefulWidget {
  const CrearClaseView({super.key});

  @override
  State<CrearClaseView> createState() => _CrearClaseViewState();
}

class _CrearClaseViewState extends State<CrearClaseView> {
  final _nombre = TextEditingController();
  final _grupo = TextEditingController();
  late final TextEditingController _docente;
  String? _error;
  bool _privada = false;

  @override
  void initState() {
    super.initState();
    final u = AppStore.instance.usuarioActual;
    _docente = TextEditingController(text: u?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _grupo.dispose();
    _docente.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (_nombre.text.trim().isEmpty || _grupo.text.trim().isEmpty) {
      setState(() => _error = 'Escribe el nombre y el grupo de la clase');
      return;
    }
    final clase = AppStore.instance.crearClase(
      nombre: _nombre.text,
      grupo: _grupo.text,
      docente: _docente.text,
      privada: _privada,
    );
    final nav = Navigator.of(context);
    nav.pop();
    await showDialog<void>(
      context: nav.context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Clase creada!'),
        content: Text(
            'Comparte este código con tu grupo:\n\n${clase.codigo}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              abrirClase(nav.context, clase);
            },
            child: const Text('Abrir clase'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Crear clase'),
              const SizedBox(height: 12),
              const TextoSuave(
                  'Serás el administrador de la clase. El código para unirse se genera solo.'),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Nombre de la clase',
                  controller: _nombre,
                  hint: 'Ej. Programación Móvil'),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Grupo', controller: _grupo, hint: 'Ej. GTID244'),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Docente (opcional)',
                  controller: _docente,
                  hint: 'Nombre del docente'),
              const SizedBox(height: 16),
              const TextoSeccion('Tipo de clase'),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        icon: Icon(Icons.public),
                        label: Text('Pública')),
                    ButtonSegment(
                        value: true,
                        icon: Icon(Icons.lock_outline),
                        label: Text('Privada')),
                  ],
                  selected: {_privada},
                  onSelectionChanged: (s) =>
                      setState(() => _privada = s.first),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _privada
                    ? 'Privada: quien tenga el código envía una solicitud y tú la apruebas o la rechazas.'
                    : 'Pública: cualquier persona entra al instante con el código de la clase.',
                style: const TextStyle(
                    fontSize: 13, height: 1.4, color: AppColores.textoSuave),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                MensajeError(_error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _crear, child: const Text('Crear clase')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
