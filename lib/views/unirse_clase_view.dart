import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/clase.dart';
import '../modelos/solicitud.dart';
import '../widgets/app_tema.dart';
import '../widgets/componentes.dart';

class UnirseClaseView extends StatefulWidget {
  const UnirseClaseView({super.key});

  @override
  State<UnirseClaseView> createState() => _UnirseClaseViewState();
}

class _UnirseClaseViewState extends State<UnirseClaseView> {
  final _codigo = TextEditingController();
  Clase? _encontrada;
  String? _error;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  void _buscar() {
    final c = AppStore.instance.buscarPorCodigo(_codigo.text);
    setState(() {
      _encontrada = c;
      _error = c == null ? 'No encontramos una clase con ese código' : null;
    });
  }

  void _accion(Clase c) {
    final store = AppStore.instance;
    if (c.privada) {
      final e = store.solicitar(c);
      if (e != null) {
        setState(() => _error = e);
        return;
      }
      mostrarMensaje(context,
          'Solicitud enviada. El administrador de la clase la revisará');
      setState(() => _error = null);
    } else {
      store.unirse(c);
      mostrarMensaje(context, 'Te uniste a ${c.nombre}');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final c = _encontrada;
    final yaEsta = c != null && store.esMiembro(c);
    final sol = c == null ? null : store.solicitudDe(c);
    final pendiente = !yaEsta && sol?.estado == EstadoSolicitud.pendiente;
    final rechazada = !yaEsta && sol?.estado == EstadoSolicitud.rechazada;

    String textoBoton = 'Unirme a esta clase';
    if (c != null) {
      if (yaEsta) {
        textoBoton = 'Ya perteneces a esta clase';
      } else if (pendiente) {
        textoBoton = 'Solicitud enviada';
      } else if (c.privada) {
        textoBoton = rechazada ? 'Volver a solicitar' : 'Solicitar unirme';
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Encabezado(titulo: 'Unirme a una clase'),
              const SizedBox(height: 12),
              const TextoSuave(
                  'Pide el código a tu docente o a un compañero de grupo.'),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Código de clase',
                controller: _codigo,
                hint: 'Ej. GTID244-DAM',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _buscar, child: const Text('Buscar clase')),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                MensajeError(_error!),
              ],
              if (c != null) ...[
                const SizedBox(height: 20),
                const TextoSeccion('Clase encontrada'),
                const SizedBox(height: 8),
                TarjetaClase(
                    clase: c, detalleExtra: '${store.alumnosDe(c).length} alumnos'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(c.privada ? Icons.lock_outline : Icons.public,
                        size: 18, color: AppColores.textoSuave),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextoSuave(c.privada
                          ? 'Clase privada: el administrador debe aprobar tu solicitud.'
                          : 'Clase pública: entras al instante con el código.'),
                    ),
                  ],
                ),
                if (pendiente) ...[
                  const SizedBox(height: 12),
                  const _Aviso(
                      'Tu solicitud está pendiente. Te avisaremos en Mis clases cuando la respondan.',
                      AppColores.primario),
                ],
                if (rechazada) ...[
                  const SizedBox(height: 12),
                  const _Aviso(
                      'Tu solicitud anterior fue rechazada. Puedes volver a intentarlo.',
                      AppColores.error),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (yaEsta || pendiente) ? null : () => _accion(c),
                    child: Text(textoBoton),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto, this.color);

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(texto,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}
