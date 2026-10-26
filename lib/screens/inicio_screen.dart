import 'package:flutter/material.dart';
import '../widgets/producto_card.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dale Otra Vuelta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Cerca de ti', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final p in productosDemo) ProductoCard(producto: p),
        ],
      ),
    );
  }
}
