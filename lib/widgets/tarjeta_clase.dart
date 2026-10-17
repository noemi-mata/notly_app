import 'package:flutter/material.dart';

import '../data/clases_repo.dart';
import '../modelos/clase.dart';
import '../tema/app_theme.dart';

class TarjetaClase extends StatelessWidget {
  const TarjetaClase({
    super.key,
    required this.clase,
    this.onTap,
    this.trailing,
    this.mostrarApuntes = true,
  });

  final Clase clase;
  final VoidCallback? onTap;

  /// Widget a la derecha: los tres puntitos, el botón "Mostrar", etc.
  final Widget? trailing;
  final bool mostrarApuntes;

  @override
  Widget build(BuildContext context) {
    final total = ClasesRepo.instance.apuntesDe(clase.id).length;
    final textoApuntes = total == 1 ? '1 apunte' : '$total apuntes';

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColores.bordeTarjeta, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: clase.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  clase.iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clase.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColores.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clase.detalle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColores.textoSuave,
                      ),
                    ),
                    if (mostrarApuntes) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            textoApuntes,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColores.primario,
                            ),
                          ),
                          if (clase.esAdmin) ...[
                            const SizedBox(width: 8),
                            const _InsigniaAdmin(),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _InsigniaAdmin extends StatelessWidget {
  const _InsigniaAdmin();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColores.texto,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'ADMIN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
