import 'package:flutter/material.dart';
import '../models/sesion.dart';
import '../screens/login_screen.dart';

/// Piezas reutilizables para los tres dashboards.
class DashboardScaffold extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const DashboardScaffold({super.key, required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (r) => false,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hola, ${Sesion.nombre}',
              style: Theme.of(context).textTheme.headlineSmall),
          Text('${Sesion.rol.nombre} · ${Sesion.municipio}'),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  const StatCard({super.key, required this.icono, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: cs.onSecondaryContainer),
            const SizedBox(height: 8),
            Text(valor, style: Theme.of(context).textTheme.headlineSmall),
            Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Fila de dos tarjetas de estadísticas.
Widget filaStats(List<StatCard> items) {
  return Row(
    children: [
      for (var i = 0; i < items.length; i++) ...[
        Expanded(child: items[i]),
        if (i < items.length - 1) const SizedBox(width: 8),
      ],
    ],
  );
}
