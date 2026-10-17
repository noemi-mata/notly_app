import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class BotonAtras extends StatelessWidget {
  const BotonAtras({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColores.borde, width: 1.5),
      ),
      child: IconButton(
        tooltip: 'Volver',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.chevron_left, color: AppColores.texto),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Encabezado de pantallas internas: botón atrás + título.
class Encabezado extends StatelessWidget {
  const Encabezado({super.key, required this.titulo, this.tamano = 22});

  final String titulo;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BotonAtras(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: tamano,
              fontWeight: FontWeight.w800,
              color: AppColores.texto,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
