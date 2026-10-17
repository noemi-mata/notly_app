import 'package:flutter/material.dart';

import '../modelos/apunte.dart';
import '../tema/app_theme.dart';

class TarjetaApunte extends StatelessWidget {
  const TarjetaApunte({super.key, required this.apunte, this.onDescargar});

  final Apunte apunte;
  final VoidCallback? onDescargar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: apunte.tipo.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              apunte.tipo.etiqueta,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apunte.tema,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${apunte.materia} · Subido por ${apunte.autor}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColores.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColores.azulSuave,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Descargar',
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.file_download_outlined,
                  color: AppColores.primario),
              onPressed: onDescargar,
            ),
          ),
        ],
      ),
    );
  }
}
