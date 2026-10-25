import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';
import 'admin_solicitudes_view.dart';
import 'agregar_materia_view.dart';
import 'alumnos_clase_view.dart';

/// Opciones de la clase: solo la ven el administrador de la clase
/// (quien la creó) y el administrador general.
class OpcionesClaseView extends StatelessWidget {
  const OpcionesClaseView({super.key, required this.claseId});

  final String claseId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final clase = store.clasePorId(claseId);

        if (clase == null || !store.puedeAdministrar(clase)) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Encabezado(titulo: 'Opciones de clase'),
                    Expanded(
                        child: EstadoVacio(
                            'Solo los administradores de la clase pueden ver estas opciones')),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: MenuInferior(),
          );
        }

        final materias = store.materiasDe(clase.id);
        final enlace = 'notly://unirse/${clase.codigo}';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Encabezado(
                    titulo: 'Opciones de clase',
                    acciones: [Insignia('ADMIN')],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColores.azulSuave,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                        'Solo los administradores de esta clase pueden ver estas opciones.',
                        style: TextStyle(fontSize: 13, height: 1.4)),
                  ),
                  const SizedBox(height: 16),
                  TarjetaClase(
                      clase: clase,
                      detalleExtra: '${store.alumnosDe(clase).length} alumnos'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColores.bordeTarjeta, width: 1.5),
                    ),
                    child: SwitchListTile(
                      value: clase.privada,
                      onChanged: (v) => store.cambiarPrivacidad(clase, v),
                      secondary: Icon(
                          clase.privada ? Icons.lock_outline : Icons.public),
                      title: Text(
                          clase.privada ? 'Clase privada' : 'Clase pública',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(clase.privada
                          ? 'Quien tenga el código envía una solicitud y tú la apruebas.'
                          : 'Cualquiera entra al instante con el código.'),
                    ),
                  ),
                  if (clase.privada) ...[
                    const SizedBox(height: 12),
                    TarjetaOpcion(
                      icono: Icons.how_to_reg_outlined,
                      color: AppColores.morado,
                      titulo: 'Solicitudes de ingreso',
                      subtitulo: store.solicitudesPendientesDe(clase).isEmpty
                          ? 'Sin solicitudes pendientes'
                          : '${store.solicitudesPendientesDe(clase).length} pendientes por responder',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AdminSolicitudesView()),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TarjetaOpcion(
                    icono: Icons.people_outline,
                    color: AppColores.primario,
                    titulo: 'Alumnos inscritos',
                    subtitulo: '${store.alumnosDe(clase).length} alumnos · ver o sacar',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AlumnosClaseView(claseId: clase.id)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextoSeccion('Compartir clase'),
                  const SizedBox(height: 6),
                  const TextoSuave('Tus compañeros pueden unirse con este código.'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColores.primario, width: 1.5),
                    ),
                    child: Text(clase.codigo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52)),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: clase.codigo));
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
                            // Con el paquete share_plus aquí se abriría el menú
                            // de compartir del sistema.
                            await Clipboard.setData(ClipboardData(
                                text:
                                    'Únete a "${clase.nombre}" en Notly con el código ${clase.codigo}\n$enlace'));
                            if (context.mounted) {
                              mostrarMensaje(
                                  context, 'Enlace copiado para compartir');
                            }
                          },
                          child: const Text('Compartir enlace',
                              style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: TextoSeccion('Materias y unidades')),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  AgregarMateriaView(claseId: clase.id)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  if (materias.isEmpty)
                    const TextoSuave('Esta clase aún no tiene materias ni unidades.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final m in materias)
                          Chip(
                            avatar: Icon(
                                m.esUnidad
                                    ? Icons.folder_outlined
                                    : Icons.menu_book_outlined,
                                size: 16),
                            label: Text(m.nombre),
                          ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColores.errorSuave,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0C9C4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Eliminar clase',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColores.error)),
                        const SizedBox(height: 6),
                        const TextoSuave(
                            'Se borrará la clase con sus materias y apuntes. Esta acción no se puede deshacer.'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              backgroundColor: Colors.white,
                              foregroundColor: AppColores.error,
                              side: const BorderSide(
                                  color: AppColores.error, width: 1.5),
                            ),
                            onPressed: () async {
                              final ok = await confirmar(
                                context,
                                titulo: 'Eliminar clase',
                                mensaje:
                                    '¿Eliminar "${clase.nombre}"? No se puede deshacer.',
                                textoAccion: 'Eliminar',
                                peligro: true,
                              );
                              if (!ok || !context.mounted) return;
                              final nav = Navigator.of(context);
                              store.eliminarClase(clase.id);
                              nav.popUntil((r) => r.isFirst);
                            },
                            child: const Text('Eliminar clase'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const MenuInferior(activa: Seccion.administrar),
        );
      },
    );
  }
}
