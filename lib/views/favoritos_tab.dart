import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';
import 'acciones_apunte.dart';

class FavoritosTab extends StatelessWidget {
  const FavoritosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final lista = AppStore.instance.favoritosDelUsuario;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TituloPagina('Favoritos'),
            const SizedBox(height: 16),
            Expanded(
              child: lista.isEmpty
                  ? const EstadoVacio(
                      'Aún no tienes favoritos. Toca un apunte y elige "Agregar a favoritos".',
                      icono: Icons.star_border)
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
