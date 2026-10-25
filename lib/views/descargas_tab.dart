import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';
import 'acciones_apunte.dart';

class DescargasTab extends StatelessWidget {
  const DescargasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final lista = AppStore.instance.descargasDelUsuario;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TituloPagina('Descargas'),
            const SizedBox(height: 16),
            Expanded(
              child: lista.isEmpty
                  ? const EstadoVacio(
                      'Todavía no has descargado apuntes.',
                      icono: Icons.file_download_outlined)
                  : ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => TarjetaApunte(
                        apunte: lista[i],
                        mostrarClase: true,
                        onTap: () => mostrarAccionesApunte(context, lista[i]),
                        onDescargar: () => descargarApunte(context, lista[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
