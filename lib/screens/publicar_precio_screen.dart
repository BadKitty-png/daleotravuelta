import 'package:flutter/material.dart';

/// Pantalla 3 (parte 2) — Precio y ubicación
class PublicarPrecioScreen extends StatefulWidget {
  const PublicarPrecioScreen({super.key});

  @override
  State<PublicarPrecioScreen> createState() => _PublicarPrecioScreenState();
}

class _PublicarPrecioScreenState extends State<PublicarPrecioScreen> {
  bool _acepto = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Precio y Ubicación', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Precio', prefixText: '\$ '),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Acepto ofertas'),
            value: _acepto,
            onChanged: (v) => setState(() => _acepto = v),
          ),
          const SizedBox(height: 8),
          Text('¿Dónde está?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            height: 180,
            color: cs.surfaceContainerHighest,
            child: const Center(child: Icon(Icons.map_outlined, size: 48)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Colonia'),
            initialValue: 'Col. Centro',
            items: const ['Col. Centro', 'Col. San Juan', 'Col. Las Américas']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publicación simulada (sin funcionalidad aún)')),
              );
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}
