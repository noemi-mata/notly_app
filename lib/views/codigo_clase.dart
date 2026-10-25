import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modelos/clase.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';

/// Muestra el código de la clase con botones para copiarlo o compartirlo.
/// Lo puede usar cualquier miembro de la clase.
void mostrarCodigoClase(BuildContext context, Clase clase) {
  final enlace = 'notly://unirse/${clase.codigo}';
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Código de la clase',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(clase.nombre,
              style: const TextStyle(color: AppColores.textoSuave)),
          const SizedBox(height: 4),
          TextoSuave(clase.privada
              ? 'Clase privada: quien use el código enviará una solicitud que el administrador aprobará.'
              : 'Clase pública: quien use el código entra al instante.'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColores.primario, width: 1.5),
            ),
            child: SelectableText(clase.codigo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: clase.codigo));
                    if (context.mounted) {
                      mostrarMensaje(context, 'Código copiado');
                    }
                  },
                  child: const Text('Copiar código'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(
                        text:
                            'Únete a "${clase.nombre}" en Notly con el código ${clase.codigo}\n$enlace'));
                    if (context.mounted) {
                      mostrarMensaje(context, 'Enlace copiado para compartir');
                    }
                  },
                  child: const Text('Compartir enlace',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
