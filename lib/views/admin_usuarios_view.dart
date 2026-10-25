import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/usuario.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';
import '../widgets/menu_inferior.dart';

class AdminUsuariosView extends StatefulWidget {
  const AdminUsuariosView({super.key});

  @override
  State<AdminUsuariosView> createState() => _AdminUsuariosViewState();
}

class _AdminUsuariosViewState extends State<AdminUsuariosView> {
  final _buscar = TextEditingController();
  int _filtro = 0; // 0 todos, 1 activos, 2 suspendidos

  @override
  void dispose() {
    _buscar.dispose();
    super.dispose();
  }

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
              final q = _buscar.text.trim().toLowerCase();
              final lista = store.usuarios.where((u) {
                final okTexto = q.isEmpty ||
                    u.nombre.toLowerCase().contains(q) ||
                    u.correo.toLowerCase().contains(q);
                final okFiltro = _filtro == 0 ||
                    (_filtro == 1 && !u.suspendido) ||
                    (_filtro == 2 && u.suspendido);
                return okTexto && okFiltro;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Encabezado(
                    titulo: 'Usuarios',
                    acciones: const [Insignia('ADMIN')],
                  ),
                  const SizedBox(height: 16),
                  CampoBusqueda(
                    controller: _buscar,
                    hint: 'Buscar por nombre o correo…',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final (i, t) in ['Todos', 'Activos', 'Suspendidos'].indexed)
                        ChoiceChip(
                          label: Text(t),
                          selected: _filtro == i,
                          onSelected: (_) => setState(() => _filtro = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: lista.isEmpty
                        ? const EstadoVacio('No hay usuarios con ese filtro')
                        : ListView.separated(
                            itemCount: lista.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _TarjetaUsuario(usuario: lista[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const MenuInferior(activa: Seccion.administrar),
    );
  }
}

class _TarjetaUsuario extends StatelessWidget {
  const _TarjetaUsuario({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final esYo = usuario.id == store.usuarioActual?.id;
    final esAdmin = usuario.esAdministrador;
    final creadas = store.clases.where((c) => c.creadorId == usuario.id).length;
    final color = esAdmin
        ? AppColores.texto
        : creadas > 0
            ? AppColores.morado
            : AppColores.primario;
    final roles = esAdmin ? 'Administrador' : 'Alumno · Docente';

    return TarjetaBase(
      child: Row(
        children: [
          AvatarCuadrado(texto: usuario.iniciales, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nombre,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                    '$roles · ${usuario.suspendido ? 'Suspendido' : 'Activo'}',
                    style: TextStyle(
                        fontSize: 12,
                        color: usuario.suspendido
                            ? AppColores.error
                            : AppColores.textoSuave)),
                Text(usuario.correo,
                    style: const TextStyle(
                        fontSize: 12, color: AppColores.textoSuave)),
              ],
            ),
          ),
          if (!esYo)
            PopupMenuButton<String>(
              tooltip: 'Acciones del usuario',
              icon: const Icon(Icons.manage_accounts_outlined),
              onSelected: (v) async {
                String? error;
                if (v == 'hacer') {
                  final ok = await confirmar(
                    context,
                    titulo: 'Hacer administrador',
                    mensaje:
                        '¿Dar el rol de administrador a ${usuario.nombre}? Podrá gestionar usuarios y todas las clases.',
                    textoAccion: 'Hacer administrador',
                  );
                  if (!ok) return;
                  error = store.hacerAdministrador(usuario);
                  if (error == null && context.mounted) {
                    mostrarMensaje(context,
                        '${usuario.nombre} ahora es administrador');
                  }
                } else if (v == 'quitar') {
                  final ok = await confirmar(
                    context,
                    titulo: 'Quitar administrador',
                    mensaje:
                        '¿Quitar el rol de administrador a ${usuario.nombre}?',
                    textoAccion: 'Quitar',
                    peligro: true,
                  );
                  if (!ok) return;
                  error = store.quitarAdministrador(usuario);
                } else if (v == 'suspender') {
                  store.alternarSuspension(usuario);
                }
                if (error != null && context.mounted) {
                  mostrarMensaje(context, error);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: esAdmin ? 'quitar' : 'hacer',
                  child: Text(esAdmin
                      ? 'Quitar rol de administrador'
                      : 'Hacer administrador'),
                ),
                if (!esAdmin)
                  PopupMenuItem(
                    value: 'suspender',
                    child: Text(usuario.suspendido
                        ? 'Reactivar cuenta'
                        : 'Suspender cuenta'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
