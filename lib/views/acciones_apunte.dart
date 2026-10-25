import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/archivos_service.dart';
import '../modelos/apunte.dart';
import '../widgets/componentes.dart';
import 'apunte_descargado_view.dart';
import 'apunte_view.dart';

/// Descarga el apunte: lo guarda en Notly (pestaña Descargas) y además
/// lo guarda de verdad en el dispositivo.
Future<void> descargarApunte(BuildContext context, Apunte apunte) async {
  final nav = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await AppStore.instance.registrarDescarga(apunte);
  final error =
      await ArchivosService.guardarEnDispositivo(apunte.nombreArchivo, apunte.rutas);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(error ?? 'Apunte guardado en tu dispositivo')));
  nav.push(
    MaterialPageRoute(builder: (_) => ApunteDescargadoView(apunteId: apunte.id)),
  );
}

Future<void> reportarApunte(BuildContext context, Apunte apunte) async {
  const motivos = [
    'Contenido ajeno a la materia',
    'Archivo ilegible',
    'Contenido duplicado',
    'Contenido inapropiado',
  ];
  final motivo = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('¿Por qué reportas este apunte?'),
      children: [
        for (final m in motivos)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, m),
            child: Text(m),
          ),
      ],
    ),
  );
  if (motivo == null || !context.mounted) return;
  final ok = AppStore.instance.reportar(apunte, motivo);
  mostrarMensaje(
    context,
    ok ? 'Reporte enviado. Gracias por avisar' : 'Ya reportaste este apunte',
  );
}

/// Al tocar un apunte se abre su vista previa con todas las acciones.
void mostrarAccionesApunte(BuildContext context, Apunte apunte) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ApunteView(apunteId: apunte.id)),
  );
}
