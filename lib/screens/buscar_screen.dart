import 'package:flutter/material.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/producto_card.dart';
import 'filtros_screen.dart';

/// Pantalla 4 — Buscar en la App (búsqueda por texto y chips de categoría)
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  static const _categorias = ['Todo', 'Bicicletas', 'Tecnología', 'Muebles'];

  // Palabras clave por categoría (solo para la maqueta).
  static const _claves = {
    'Bicicletas': ['bicicleta'],
    'Tecnología': ['audífonos', 'inalámbricos'],
    'Muebles': ['silla'],
  };

  String _texto = '';
  String _categoria = 'Todo';

  List<Producto> get _resultados {
    return productosDemo.where((p) {
      final base = '${p.titulo} ${p.descripcion}'.toLowerCase();
      final okTexto = _texto.isEmpty || base.contains(_texto.toLowerCase());
      final okCat = _categoria == 'Todo' ||
          (_claves[_categoria] ?? []).any((k) => base.contains(k));
      return okTexto && okCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _texto = v.trim()),
                  decoration: const InputDecoration(
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
            children: [
              for (final c in _categorias)
                ChoiceChip(
                  label: Text(c),
                  selected: _categoria == c,
                  onSelected: (_) => setState(() => _categoria = c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (resultados.isEmpty)
            const EstadoVacio(
              mensaje: 'No hay elementos',
              detalle: 'Prueba con otra búsqueda o cambia la categoría.',
              icono: Icons.search_off,
            )
          else
            for (final p in resultados) ProductoCard(producto: p),
        ],
      ),
    );
  }
}
