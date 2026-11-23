import 'package:flutter/material.dart';

import '../widgets/estado_vacio.dart';
import '../widgets/producto_card.dart';
import '../widgets/estilo_app.dart';
import 'filtros_screen.dart';

/// Pantalla de búsqueda de Dale la Vuelta.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  static const _categorias = ['Todo', 'Bicicletas', 'Tecnología', 'Muebles'];

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

      final okCat =
          _categoria == 'Todo' ||
          (_claves[_categoria] ?? []).any((k) => base.contains(k));

      return okTexto && okCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;

    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Buscar',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DaleColores.verdeLima.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: DaleColores.verdeBosque,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          // Encabezado visual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: DecoracionOrganica()),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Encuentra algo especial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Dale una nueva vida a los objetos.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const LogoDaleVuelta(size: 66),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Buscador y filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _texto = v.trim()),
                  style: const TextStyle(
                    color: DaleColores.carbon,
                    fontFamily: 'Roboto',
                  ),
                  decoration: InputDecoration(
                    hintText: '¿Qué estás buscando?',
                    hintStyle: const TextStyle(
                      color: DaleColores.grisMusgo,
                      fontFamily: 'Roboto',
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: DaleColores.verdeBosque,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: DaleColores.borde),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: DaleColores.borde),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: DaleColores.verdeBosque,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: DaleColores.verdeBosque,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: DaleColores.verdeBosque.withOpacity(0.20),
                      blurRadius: 9,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: 'Filtros',
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FiltrosScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Explora categorías',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in _categorias)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: _categoria == c,
                      onSelected: (_) => setState(() => _categoria = c),
                      selectedColor: DaleColores.verdeBosque,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _categoria == c
                            ? Colors.white
                            : DaleColores.grisMusgo,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                      side: BorderSide(
                        color: _categoria == c
                            ? DaleColores.verdeBosque
                            : DaleColores.borde,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(
                  color: DaleColores.carbon,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              Text(
                '${resultados.length} encontrados',
                style: const TextStyle(
                  color: DaleColores.grisMusgo,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

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
