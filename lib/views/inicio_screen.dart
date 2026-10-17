import 'package:flutter/material.dart';

import '../data/clases_repo.dart';
import '../modelos/clase.dart';
import '../tema/app_theme.dart';
import '../widgets/menu_inferior.dart';
import '../widgets/tarjeta_clase.dart';
import 'clase_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _busqueda = TextEditingController();
  String _filtro = '';
  bool _verOcultas = false;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  String _normalizar(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');

  List<Clase> _filtrar(List<Clase> clases) {
    final q = _normalizar(_filtro.trim());
    if (q.isEmpty) return clases;
    return clases
        .where((c) =>
            _normalizar(c.nombre).contains(q) ||
            _normalizar(c.docente).contains(q) ||
            _normalizar(c.grupo).contains(q))
        .toList();
  }

  Future<void> _unirse() async {
    final controlador = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unirme a una clase'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Ej. GTID244-BD'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, controlador.text),
            child: const Text('Unirme'),
          ),
        ],
      ),
    );
    if (codigo == null || codigo.trim().isEmpty || !mounted) return;

    final repo = ClasesRepo.instance;
    final clase = repo.buscarPorCodigo(codigo);
    String mensaje;
    if (clase == null) {
      mensaje = 'No se encontró ninguna clase con ese código';
    } else if (repo.yaPertenece(clase)) {
      mensaje = 'Ya perteneces a ${clase.nombre}';
    } else {
      repo.unirse(clase);
      mensaje = 'Te uniste a ${clase.nombre}';
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _abrirClase(Clase clase) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ClaseScreen(clase: clase)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MenuInferior(actual: Seccion.clases),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ClasesRepo.instance,
          builder: (context, _) {
            final repo = ClasesRepo.instance;
            final totalOcultas = repo.ocultas.length;

            // Si ya no quedan ocultas, regresamos a la vista normal.
            final verOcultas = _verOcultas && totalOcultas > 0;
            final lista = _filtrar(verOcultas ? repo.ocultas : repo.visibles);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Mis clases',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 16),

                // Barra de búsqueda
                TextField(
                  controller: _busqueda,
                  onChanged: (v) => setState(() => _filtro = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar clases',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filtro.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _busqueda.clear();
                              setState(() => _filtro = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Botón unirme
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: _unirse,
                    child: const Text('Unirme a una clase'),
                  ),
                ),
                const SizedBox(height: 20),

                // Título de la sección + botón de clases ocultas
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        verOcultas ? 'Clases ocultas' : 'Clases en las que estás',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColores.texto,
                        ),
                      ),
                    ),
                    if (verOcultas)
                      OutlinedButton(
                        onPressed: () => setState(() => _verOcultas = false),
                        child: const Text('Mis clases'),
                      )
                    else if (totalOcultas > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _verOcultas = true),
                        child: Text('Clases ocultas ($totalOcultas)'),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                if (lista.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        _filtro.trim().isNotEmpty
                            ? 'Ninguna clase coincide con tu búsqueda'
                            : verOcultas
                                ? 'No tienes clases ocultas'
                                : 'No tienes clases visibles',
                        style: const TextStyle(color: AppColores.textoSuave),
                      ),
                    ),
                  ),

                for (final clase in lista) ...[
                  if (verOcultas)
                    TarjetaClase(
                      clase: clase,
                      mostrarApuntes: false,
                      trailing: OutlinedButton(
                        onPressed: () => repo.mostrar(clase),
                        child: const Text('Mostrar'),
                      ),
                    )
                  else
                    TarjetaClase(
                      clase: clase,
                      onTap: () => _abrirClase(clase),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Opciones',
                        onSelected: (_) => repo.ocultar(clase),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'ocultar',
                            child: Text('Ocultar clase'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
