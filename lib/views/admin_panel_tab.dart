import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import 'admin_clases_view.dart';
import 'admin_moderacion_view.dart';
import 'admin_solicitudes_view.dart';
import 'admin_usuarios_view.dart';

class AdminPanelTab extends StatelessWidget {
  const AdminPanelTab({super.key});

  void _ir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final store = AppStore.instance;
        final esAdminGeneral = store.esAdministradorGeneral;
        final clases = store.clasesAdministrables;
        final mias = store.clasesCreadas;
        final ids = clases.map((c) => c.id).toSet();
        final apuntes = store.apuntes.where((a) => ids.contains(a.claseId)).length;
        final reportes = store.reportesModerables.length;
        final solicitudes = store.solicitudesPorResponder.length;
        final alumnos = <String>{for (final c in clases) ...c.miembros}.length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TituloPagina(
                'Panel',
                derecha: Insignia(esAdminGeneral ? 'ADMINISTRADOR' : 'DOCENTE'),
              ),
              const SizedBox(height: 4),
              TextoSuave(esAdminGeneral
                  ? 'Resumen de Notly.'
                  : 'Resumen de tus clases.'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.7,
                children: [
                  if (esAdminGeneral)
                    MetricaCard(
                        valor: '${store.usuarios.length}',
                        etiqueta: 'Usuarios',
                        onTap: () => _ir(context, const AdminUsuariosView()))
                  else
                    MetricaCard(
                        valor: '$alumnos',
                        etiqueta: 'Personas en tus clases',
                        onTap: () => _ir(context, const AdminClasesView())),
                  MetricaCard(
                      valor: esAdminGeneral
                          ? '${store.clases.length}'
                          : '${mias.length}',
                      etiqueta: esAdminGeneral ? 'Clases' : 'Mis clases',
                      onTap: () => _ir(
                          context,
                          esAdminGeneral
                              ? const AdminClasesView(soloMias: false)
                              : const AdminClasesView())),
                  MetricaCard(
                      valor: '$apuntes',
                      etiqueta: 'Apuntes',
                      onTap: () => _ir(
                          context,
                          esAdminGeneral
                              ? const AdminClasesView(soloMias: false)
                              : const AdminClasesView())),
                  MetricaCard(
                    onTap: () => _ir(context, const AdminModeracionView()),
                    valor: '$reportes',
                    etiqueta: 'Reportes pendientes',
                    color: reportes > 0 ? AppColores.error : AppColores.primario,
                    fondo: reportes > 0 ? AppColores.errorSuave : Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const TextoSeccion('Opciones de administración'),
              const SizedBox(height: 10),
              if (esAdminGeneral) ...[
                TarjetaOpcion(
                  icono: Icons.person_outline,
                  color: AppColores.morado,
                  titulo: 'Usuarios',
                  subtitulo: 'Suspender cuentas o hacer administradores',
                  onTap: () => _ir(context, const AdminUsuariosView()),
                ),
                const SizedBox(height: 10),
              ],
              if (!esAdminGeneral)
                TarjetaOpcion(
                  icono: Icons.menu_book_outlined,
                  color: AppColores.primario,
                  titulo: 'Mis clases',
                  subtitulo: 'Las clases que creaste: ver, compartir o eliminar',
                  onTap: () => _ir(context, const AdminClasesView()),
                ),
              if (esAdminGeneral) ...[
                TarjetaOpcion(
                  icono: Icons.public,
                  color: AppColores.terracota,
                  titulo: 'Todas las clases',
                  subtitulo: '${store.clases.length} clases en Notly',
                  onTap: () => _ir(
                      context, const AdminClasesView(soloMias: false)),
                ),
              ],
              const SizedBox(height: 10),
              TarjetaOpcion(
                icono: Icons.how_to_reg_outlined,
                color: AppColores.morado,
                titulo: 'Solicitudes',
                subtitulo: solicitudes == 0
                    ? 'Sin solicitudes pendientes'
                    : '$solicitudes solicitudes para entrar a tus clases',
                onTap: () => _ir(context, const AdminSolicitudesView()),
              ),
              const SizedBox(height: 10),
              TarjetaOpcion(
                icono: Icons.verified_user_outlined,
                color: AppColores.error,
                titulo: 'Moderación',
                subtitulo: reportes == 0
                    ? 'Sin reportes pendientes'
                    : '$reportes apuntes reportados pendientes',
                onTap: () => _ir(context, const AdminModeracionView()),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
