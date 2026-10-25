import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'registro_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _correo = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _entrar() {
    final e = AppStore.instance.iniciarSesion(_correo.text, _pass.text);
    setState(() => _error = e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: AppColores.primario,
                    borderRadius: BorderRadius.circular(14)),
                child: const Text('N',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24)),
              ),
              const SizedBox(height: 16),
              const Text('Notly',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const TextoSuave(
                  'Comparte y encuentra los apuntes de tu grupo en segundos.'),
              const SizedBox(height: 24),
              CampoTexto(
                etiqueta: 'Correo',
                controller: _correo,
                hint: 'tucorreo@gmail.com',
                teclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Contraseña',
                controller: _pass,
                oculto: true,
                hint: 'Tu contraseña',
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                MensajeError(_error!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _entrar, child: const Text('Iniciar sesión')),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegistroView()),
                  ),
                  child: const Text('¿No tienes cuenta? Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
