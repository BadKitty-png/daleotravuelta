import 'package:flutter/material.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/producto_card.dart';
import 'main_shell.dart';
import 'publicar_tipo_screen.dart';

/// Dashboard — Usuario
class DashboardUsuarioScreen extends StatelessWidget {
  const DashboardUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      titulo: 'Mi panel',
      children: [
        filaStats(const [
          StatCard(icono: Icons.eco_outlined, valor: '120', etiqueta: 'Eco-puntos'),
          StatCard(icono: Icons.inventory_2_outlined, valor: '3', etiqueta: 'Publicaciones'),
        ]),
        const SizedBox(height: 8),
        filaStats(const [
          StatCard(icono: Icons.swap_horiz, valor: '1', etiqueta: 'Intercambios'),
          StatCard(icono: Icons.chat_bubble_outline, valor: '2', etiqueta: 'Chats activos'),
        ]),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MainShell()),
          ),
          icon: const Icon(Icons.explore_outlined),
          label: const Text('Explorar productos'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PublicarTipoScreen()),
          ),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Publicar un producto'),
        ),
        const SizedBox(height: 24),
        Text('Mis publicaciones recientes',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final p in productosDemo.take(2)) ProductoCard(producto: p),
      ],
    );
  }
}
