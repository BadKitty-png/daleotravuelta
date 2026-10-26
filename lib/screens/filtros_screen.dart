import 'package:flutter/material.dart';

/// Pantalla 5 — Filtros (solo interfaz, sin filtrar todavía)
class FiltrosScreen extends StatefulWidget {
  const FiltrosScreen({super.key});

  @override
  State<FiltrosScreen> createState() => _FiltrosScreenState();
}

class _FiltrosScreenState extends State<FiltrosScreen> {
  RangeValues _precio = const RangeValues(0, 20000);
  double _distancia = 10;
  final Set<String> _categorias = {};
  final Set<String> _estados = {};

  Widget _chips(List<String> opciones, Set<String> seleccion) {
    return Wrap(
      spacing: 8,
      children: [
        for (final o in opciones)
          FilterChip(
            label: Text(o),
            selected: seleccion.contains(o),
            onSelected: (v) => setState(() => v ? seleccion.add(o) : seleccion.remove(o)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Filtros')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Categoría', style: t),
          const SizedBox(height: 8),
          _chips(['Bicicletas', 'Electrónicas', 'Muebles', 'Ropa'], _categorias),
          const SizedBox(height: 24),
          Text('Precio  (\$${_precio.start.round()} a \$${_precio.end.round()})', style: t),
          RangeSlider(
            values: _precio,
            min: 0,
            max: 20000,
            divisions: 40,
            onChanged: (v) => setState(() => _precio = v),
          ),
          const SizedBox(height: 16),
          Text('Distancia  (hasta ${_distancia.round()} km)', style: t),
          Slider(
            value: _distancia,
            min: 1,
            max: 50,
            onChanged: (v) => setState(() => _distancia = v),
          ),
          const SizedBox(height: 16),
          Text('Estado', style: t),
          const SizedBox(height: 8),
          _chips(['Como nuevo', 'Buen estado', 'Para reparar'], _estados),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}
