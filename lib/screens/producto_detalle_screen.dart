import 'package:flutter/material.dart';
import '../../widgets/producto_card.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Producto producto;
  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        children: [
          Container(
            height: 240,
            color: cs.surfaceContainerHighest,
            child: const Center(child: Icon(Icons.image_outlined, size: 64)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.titulo, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(producto.precio, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Chip(label: Text(producto.modalidad)),
                const SizedBox(height: 12),
                Text(producto.descripcion),
                const SizedBox(height: 16),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.verified_outlined),
                    title: Text('Evidencia de propiedad'),
                    subtitle: Text('Número de serie y factura'),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Vendedor'),
                    subtitle: Text('Eco-puntos: 120'),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Contactar por chat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
