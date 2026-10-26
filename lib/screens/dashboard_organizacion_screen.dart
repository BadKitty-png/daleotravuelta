import 'package:flutter/material.dart';
import '../widgets/dashboard_widgets.dart';
import 'main_shell.dart';

/// Dashboard — Organización (recibe donaciones)
class DashboardOrganizacionScreen extends StatelessWidget {
  const DashboardOrganizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Panel de organización',
      children: [
        filaStats(const [
          StatCard(icono: Icons.volunteer_activism_outlined, valor: '14', etiqueta: 'Donaciones recibidas'),
          StatCard(icono: Icons.pending_actions_outlined, valor: '3', etiqueta: 'Solicitudes pendientes'),
        ]),
        const SizedBox(height: 8),
        filaStats(const [
          StatCard(icono: Icons.people_outline, valor: '27', etiqueta: 'Donantes'),
          StatCard(icono: Icons.eco_outlined, valor: '85 kg', etiqueta: 'Material reutilizado'),
        ]),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MainShell()),
          ),
          icon: const Icon(Icons.search),
          label: const Text('Buscar donaciones disponibles'),
        ),
        const SizedBox(height: 24),
        Text('Solicitudes pendientes',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            leading: Icon(Icons.chair_outlined),
            title: Text('Silla de madera'),
            subtitle: Text('Donante: María López'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.checkroom_outlined),
            title: Text('Uniforme escolar talla M'),
            subtitle: Text('Donante: Carlos Ramírez'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      ],
    );
  }
}
