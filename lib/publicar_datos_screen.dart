import 'package:flutter/material.dart';
import 'publicar_precio_screen.dart';

/// Pantalla 3 (parte 1) — Datos del producto
class PublicarDatosScreen extends StatefulWidget {
  const PublicarDatosScreen({super.key});

  @override
  State<PublicarDatosScreen> createState() => _PublicarDatosScreenState();
}

class _PublicarDatosScreenState extends State<PublicarDatosScreen> {
  String _talla = 'M';
  String _estado = 'Buen estado';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Datos de Bicicleta', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Marca'))),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Año'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Modelo')),
          const SizedBox(height: 16),
          Text('Talla', style: t),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'S', label: Text('S')),
              ButtonSegment(value: 'M', label: Text('M')),
              ButtonSegment(value: 'X', label: Text('X')),
            ],
            selected: {_talla},
            onSelectionChanged: (s) => setState(() => _talla = s.first),
          ),
          const SizedBox(height: 16),
          Text('Estado', style: t),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final e in ['Buen estado', 'Como nueva', 'Para reparar'])
                ChoiceChip(
                  label: Text(e),
                  selected: _estado == e,
                  onSelected: (_) => setState(() => _estado = e),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(labelText: 'Descripción', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Número de serie (opcional)')),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PublicarPrecioScreen()),
            ),
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}
