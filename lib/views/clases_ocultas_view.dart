import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';

class ClasesOcultasView extends StatelessWidget {
  const ClasesOcultasView({super.key});

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
              final ocultas = store.clasesOcultas;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(titulo: 'Clases ocultas'),
                  const SizedBox(height: 12),
                  const TextoSuave(
                      'No aparecen en tu inicio. Puedes volver a mostrarlas cuando quieras.'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ocultas.isEmpty
                        ? const EstadoVacio('No tienes clases ocultas',
                            icono: Icons.visibility_outlined)
                        : ListView.separated(
                            itemCount: ocultas.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final c = ocultas[i];
                              return TarjetaClase(
                                clase: c,
                                trailing: OutlinedButton(
                                  onPressed: () => store.mostrar(c),
                                  child: const Text('Mostrar'),
                                ),
                              );
                            },
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
