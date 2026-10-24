import 'package:flutter/material.dart';
import '../widgets/producto_card.dart';
import 'filtros_screen.dart';

/// Pantalla 4 — Buscar en la App
class BuscarScreen extends StatelessWidget {
  const BuscarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en la App',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.tune),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FiltrosScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Todo')),
              Chip(label: Text('Bicicletas')),
              Chip(label: Text('Tecnología')),
              Chip(label: Text('Muebles')),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in productosDemo) ProductoCard(producto: p),
        ],
      ),
    );
  }
}
