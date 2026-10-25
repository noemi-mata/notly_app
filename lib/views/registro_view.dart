import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';

class RegistroView extends StatefulWidget {
  const RegistroView({super.key});

  @override
  State<RegistroView> createState() => _RegistroViewState();
}

class _RegistroViewState extends State<RegistroView> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _crear() {
    final e = AppStore.instance.registrar(
      nombre: _nombre.text,
      correo: _correo.text,
      contrasena: _pass.text,
    );
    if (e != null) {
      setState(() => _error = e);
      return;
    }
    // Ya inició sesión: regresa a la raíz, que ahora muestra la app.
    Navigator.of(context).popUntil((r) => r.isFirst);
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
              const Encabezado(titulo: 'Crea tu cuenta'),
              const SizedBox(height: 12),
              const TextoSuave(
                  'Comparte y encuentra los apuntes de tu grupo en segundos.'),
              const SizedBox(height: 20),
              CampoTexto(
                  etiqueta: 'Nombre completo',
                  controller: _nombre,
                  hint: 'Ej. Noemi Mata Ruiz'),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Correo',
                  controller: _correo,
                  hint: 'tucorreo@gmail.com',
                  teclado: TextInputType.emailAddress),
              const SizedBox(height: 16),
              CampoTexto(
                  etiqueta: 'Contraseña',
                  controller: _pass,
                  oculto: true,
                  hint: 'Mínimo 8 caracteres'),
              const SizedBox(height: 8),
              const TextoSuave(
                  'Con una sola cuenta puedes estudiar, crear tus propias clases y administrarlas.'),
              if (_error != null) ...[
                const SizedBox(height: 16),
                MensajeError(_error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _crear, child: const Text('Crear cuenta')),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
