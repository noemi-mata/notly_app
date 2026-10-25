import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'acciones_apunte.dart';

/// Apuntes que subió la persona que tiene la sesión abierta.
class MisApuntesView extends StatelessWidget {
  const MisApuntesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: ListenableBuilder(
            listenable: AppStore.instance,
            builder: (context, _) {
              final store = AppStore.instance;
              final lista = store.subidosPor(store.usuarioActual?.id ?? '');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(titulo: 'Mis apuntes'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: lista.isEmpty
                        ? const EstadoVacio(
                            'Todavía no has subido apuntes. Entra a una clase y toca "Subir apuntes".',
                            icono: Icons.description_outlined)
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => TarjetaApunte(
                              apunte: lista[i],
                              mostrarClase: true,
                              onTap: () =>
                                  mostrarAccionesApunte(context, lista[i]),
                              onDescargar: () =>
                                  descargarApunte(context, lista[i]),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(),
    );
  }
}
