import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'agregar_apunte_view.dart';
import 'navegacion.dart';

class ApunteSubidoView extends StatelessWidget {
  const ApunteSubidoView({super.key, required this.apunteId});

  final String apunteId;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final apunte = store.apuntePorId(apunteId);
    final clase = apunte == null ? null : store.clasePorId(apunte.claseId);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              const _IconoExito(),
              const SizedBox(height: 24),
              const Text('¡Apunte subido!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextoSuave(
                'Ya está disponible para tus compañeros de ${clase?.nombre ?? 'la clase'}.',
                centrado: true,
              ),
              const SizedBox(height: 20),
              if (apunte != null)
                TarjetaArchivo(
                  nombre: apunte.nombreArchivo,
                  detalle: 'Subido por ${store.usuarioActual?.nombre ?? ''}',
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => volverAClase(Navigator.of(context)),
                  child: const Text('Ver en la lista'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: apunte == null
                      ? null
                      : () {
                          final nav = Navigator.of(context);
                          volverAClase(nav);
                          nav.push(MaterialPageRoute(
                              builder: (_) =>
                                  AgregarApunteView(claseId: apunte.claseId)));
                        },
                  child: const Text('Subir otro apunte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconoExito extends StatelessWidget {
  const _IconoExito();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration:
          const BoxDecoration(color: AppColores.exito, shape: BoxShape.circle),
      child: const Icon(Icons.check, color: Colors.white, size: 52),
    );
  }
}
