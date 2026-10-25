import 'package:flutter/material.dart';

import '../widgets/app_tema.dart';

/// Pantalla de bienvenida: logo de Notly con una animación corta.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final Animation<double> _escala =
      CurvedAnimation(parent: _control, curve: Curves.elasticOut);
  late final Animation<double> _opacidad =
      CurvedAnimation(parent: _control, curve: const Interval(0.3, 1));

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.fondo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _escala,
                      child: Container(
                        width: 112,
                        height: 112,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColores.primario,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColores.primario.withValues(alpha: 0.3),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28 * 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _opacidad,
                      child: const Column(
                        children: [
                          Text(
                            'Notly',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColores.texto,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Comparte y encuentra los apuntes de tu grupo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColores.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
