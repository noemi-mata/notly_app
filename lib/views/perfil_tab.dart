import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'mis_apuntes_view.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final u = store.usuarioActual;
        if (u == null) return const SizedBox.shrink();
        final color = u.esAdministrador
            ? AppColores.texto
            : store.clasesCreadas.isNotEmpty
                ? AppColores.morado
                : AppColores.primario;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TituloPagina('Perfil'),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    AvatarCuadrado(
                        texto: u.iniciales, color: color, tamano: 72),
                    const SizedBox(height: 12),
                    Text(u.nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(u.correo,
                        style: const TextStyle(color: AppColores.textoSuave)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: MetricaCard(
                          valor: '${store.clasesVisibles.length + store.clasesOcultas.length}',
                          etiqueta: 'Clases',
                          onTap: () => seccionActual.value = Seccion.clases)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: MetricaCard(
                          valor: '${store.subidosPor(u.id).length}',
                          etiqueta: 'Apuntes subidos',
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const MisApuntesView())))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: MetricaCard(
                          valor: '${store.descargasDelUsuario.length}',
                          etiqueta: 'Descargas',
                          onTap: () => seccionActual.value = Seccion.descargas)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: MetricaCard(
                          valor: '${store.favoritosDelUsuario.length}',
                          etiqueta: 'Favoritos',
                          onTap: () => seccionActual.value = Seccion.favoritos)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    foregroundColor: AppColores.error,
                    side: const BorderSide(color: AppColores.error, width: 1.5),
                  ),
                  onPressed: () async {
                    final ok = await confirmar(
                      context,
                      titulo: 'Cerrar sesión',
                      mensaje: '¿Quieres salir de tu cuenta?',
                      textoAccion: 'Salir',
                    );
                    if (ok) store.cerrarSesion();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
