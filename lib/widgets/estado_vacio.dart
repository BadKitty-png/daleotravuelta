import 'package:flutter/material.dart';

/// Estado vacío reutilizable ("No hay elementos").
class EstadoVacio extends StatelessWidget {
  final String mensaje;
  final String? detalle;
  final IconData icono;
  const EstadoVacio({
    super.key,
    this.mensaje = 'No hay elementos',
    this.detalle,
    this.icono = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icono, size: 72, color: cs.outline),
          const SizedBox(height: 12),
          Text(mensaje, style: Theme.of(context).textTheme.titleMedium),
          if (detalle != null) ...[
            const SizedBox(height: 4),
            Text(detalle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
