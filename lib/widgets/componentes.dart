import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../modelos/apunte.dart';
import '../modelos/clase.dart';
import 'app_tema.dart';
import 'menu_inferior.dart';

void mostrarMensaje(BuildContext context, String texto,
    {String? accion, VoidCallback? alAccion}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        action: accion == null
            ? null
            : SnackBarAction(label: accion, onPressed: alAccion ?? () {}),
      ),
    );
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoAccion,
  bool peligro = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(textoAccion,
              style: TextStyle(
                  color: peligro ? AppColores.error : AppColores.primario,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return r ?? false;
}

class Insignia extends StatelessWidget {
  const Insignia(this.texto, {super.key, this.color = AppColores.texto});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class AvatarCuadrado extends StatelessWidget {
  const AvatarCuadrado({
    super.key,
    required this.texto,
    required this.color,
    this.tamano = 48,
  });

  final String texto;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        texto,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class BotonAtras extends StatelessWidget {
  const BotonAtras({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColores.borde, width: 1.5),
      ),
      child: IconButton(
        tooltip: 'Volver',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.chevron_left, color: AppColores.texto),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class Encabezado extends StatelessWidget {
  const Encabezado({
    super.key,
    required this.titulo,
    this.tamano = 22,
    this.acciones = const [],
  });

  final String titulo;
  final double tamano;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BotonAtras(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: tamano,
              fontWeight: FontWeight.w800,
              color: AppColores.texto,
              height: 1.2,
            ),
          ),
        ),
        ...acciones,
        const MenuEsquina(),
      ],
    );
  }
}

class TituloPagina extends StatelessWidget {
  const TituloPagina(this.texto, {super.key, this.derecha});

  final String texto;
  final Widget? derecha;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColores.texto),
          ),
        ),
        if (derecha != null) derecha!,
        const MenuEsquina(),
      ],
    );
  }
}

class TextoSeccion extends StatelessWidget {
  const TextoSeccion(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(texto,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColores.texto));
  }
}

class TextoSuave extends StatelessWidget {
  const TextoSuave(this.texto, {super.key, this.centrado = false});

  final String texto;
  final bool centrado;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: centrado ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
          fontSize: 14, height: 1.4, color: AppColores.textoSuave),
    );
  }
}

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.hint,
    this.oculto = false,
    this.teclado,
    this.onChanged,
    this.enabled = true,
  });

  final String etiqueta;
  final TextEditingController controller;
  final String? hint;
  final bool oculto;
  final TextInputType? teclado;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColores.texto)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: oculto,
          keyboardType: teclado,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class CampoBusqueda extends StatelessWidget {
  const CampoBusqueda({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColores.textoSuave),
      ),
    );
  }
}

class MensajeError extends StatelessWidget {
  const MensajeError(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColores.errorSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C9C4)),
      ),
      child: Text(texto,
          style: const TextStyle(
              color: AppColores.error,
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  const EstadoVacio(this.texto, {super.key, this.icono = Icons.inbox_outlined});

  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 40, color: AppColores.textoSuave),
            const SizedBox(height: 12),
            TextoSuave(texto, centrado: true),
          ],
        ),
      ),
    );
  }
}

class TarjetaBase extends StatelessWidget {
  const TarjetaBase({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}

class TarjetaClase extends StatelessWidget {
  const TarjetaClase({
    super.key,
    required this.clase,
    this.onTap,
    this.trailing,
    this.detalleExtra,
  });

  final Clase clase;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Texto azul bajo el detalle (por defecto, el número de apuntes).
  final String? detalleExtra;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final total = store.apuntesDe(clase.id).length;
    final extra = detalleExtra ?? (total == 1 ? '1 apunte' : '$total apuntes');

    return TarjetaBase(
      onTap: onTap,
      child: Row(
        children: [
          AvatarCuadrado(texto: clase.iniciales, color: clase.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clase.nombre,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto)),
                const SizedBox(height: 2),
                Text(clase.detalle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColores.textoSuave)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(extra,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColores.primario)),
                    if (store.esCreador(clase)) ...[
                      const SizedBox(width: 8),
                      const Insignia('ADMIN'),
                    ],
                    if (clase.privada) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline,
                          size: 14, color: AppColores.textoSuave),
                      const SizedBox(width: 2),
                      const Text('Privada',
                          style: TextStyle(
                              fontSize: 11, color: AppColores.textoSuave)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class TarjetaApunte extends StatelessWidget {
  const TarjetaApunte({
    super.key,
    required this.apunte,
    this.onTap,
    this.onDescargar,
    this.mostrarClase = false,
  });

  final Apunte apunte;
  final VoidCallback? onTap;
  final VoidCallback? onDescargar;
  final bool mostrarClase;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final materia = store.materiaPorId(apunte.materiaId)?.nombre ?? '';
    final clase = store.clasePorId(apunte.claseId)?.nombre ?? '';
    final sub = '$materia · Subido por ${store.nombreAutor(apunte.autorId)}';

    return TarjetaBase(
      onTap: onTap,
      child: Row(
        children: [
          AvatarCuadrado(
              texto: apunte.tipo.etiqueta, color: apunte.tipo.color, tamano: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(apunte.tema,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColores.texto)),
                    ),
                    if (store.esFavorito(apunte)) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 14, color: Color(0xFFD99A00)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColores.textoSuave)),
                if (mostrarClase)
                  Text(clase,
                      style: const TextStyle(
                          fontSize: 12, color: AppColores.textoSuave)),
              ],
            ),
          ),
          if (onDescargar != null)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColores.azulSuave,
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                tooltip: 'Descargar',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.file_download_outlined,
                    color: AppColores.primario),
                onPressed: onDescargar,
              ),
            ),
        ],
      ),
    );
  }
}

class TarjetaArchivo extends StatelessWidget {
  const TarjetaArchivo({
    super.key,
    required this.nombre,
    required this.detalle,
    this.onTap,
    this.trailing,
  });

  final String nombre;
  final String detalle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tipo = tipoDesdeNombre(nombre);
    return TarjetaBase(
      onTap: onTap,
      child: Row(
        children: [
          AvatarCuadrado(texto: tipo.etiqueta, color: tipo.color, tamano: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto)),
                const SizedBox(height: 2),
                Text(detalle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColores.textoSuave)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class TarjetaOpcion extends StatelessWidget {
  const TarjetaOpcion({
    super.key,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto)),
                const SizedBox(height: 2),
                Text(subtitulo,
                    style: const TextStyle(
                        fontSize: 12, color: AppColores.textoSuave)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColores.textoSuave),
        ],
      ),
    );
  }
}

class MetricaCard extends StatelessWidget {
  const MetricaCard({
    super.key,
    required this.valor,
    required this.etiqueta,
    this.color = AppColores.primario,
    this.fondo = Colors.white,
    this.onTap,
  });

  final String valor;
  final String etiqueta;
  final Color color;
  final Color fondo;

  /// Si se pasa, al tocar la tarjeta se abre la pantalla correspondiente.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fondo,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(valor,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: color)),
              Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 13, color: AppColores.textoSuave)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja de ejemplo para la vista previa de un apunte.
class HojaPrevia extends StatelessWidget {
  const HojaPrevia({
    super.key,
    required this.titulo,
    required this.paginas,
    this.alto = 260,
  });

  final String titulo;
  final int paginas;
  final double alto;

  @override
  Widget build(BuildContext context) {
    const anchos = [0.92, 0.78, 0.88, 0.60, 0.95, 0.70, 0.85];
    return Container(
      height: alto,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColores.texto)),
              const SizedBox(height: 12),
              for (final a in anchos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FractionallySizedBox(
                    widthFactor: a,
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Insignia('Página 1 de $paginas'),
          ),
        ],
      ),
    );
  }
}
