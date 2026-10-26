import 'package:flutter/material.dart';
import '../widgets/dashboard_widgets.dart';
import 'main_shell.dart';

/// Dashboard — Administrador (moderación)
class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Panel de administración',
      children: [
        filaStats(const [
          StatCard(icono: Icons.people_outline, valor: '248', etiqueta: 'Usuarios'),
          StatCard(icono: Icons.inventory_2_outlined, valor: '96', etiqueta: 'Publicaciones activas'),
        ]),
        const SizedBox(height: 8),
        filaStats(const [
          StatCard(icono: Icons.flag_outlined, valor: '5', etiqueta: 'Reportes abiertos'),
          StatCard(icono: Icons.rule_outlined, valor: '8', etiqueta: 'Por revisar'),
        ]),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MainShell()),
          ),
          icon: const Icon(Icons.list_alt_outlined),
          label: const Text('Ver todas las publicaciones'),
        ),
        const SizedBox(height: 24),
        Text('Publicaciones por revisar',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.pedal_bike),
            title: const Text('Bicicleta de montaña rodada 26'),
            subtitle: const Text('Falta validar evidencia de propiedad'),
            trailing: Wrap(
              children: [
                IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: () {}),
                IconButton(icon: const Icon(Icons.cancel_outlined), onPressed: () {}),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.headphones_outlined),
            title: const Text('Audífonos inalámbricos'),
            subtitle: const Text('Reportado por un usuario'),
            trailing: Wrap(
              children: [
                IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: () {}),
                IconButton(icon: const Icon(Icons.cancel_outlined), onPressed: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
