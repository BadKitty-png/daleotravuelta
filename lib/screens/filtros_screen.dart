import 'package:flutter/material.dart';

import '../database/base_datos.dart';
import '../widgets/estilo_app.dart';

class FiltrosScreen extends StatefulWidget {
  final Map<String, dynamic>? filtrosActuales;

  const FiltrosScreen({super.key, this.filtrosActuales});

  @override
  State<FiltrosScreen> createState() => _FiltrosScreenState();
}

class _FiltrosScreenState extends State<FiltrosScreen> {
  List<String> _categoriasDisponibles = [];

  final Set<String> _categoriasSeleccionadas = {};
  final Set<String> _estadosSeleccionados = {};

  RangeValues _precio = const RangeValues(0, 20000);

  bool _cargandoCategorias = true;

  final List<String> _estadosDisponibles = [
    'Como nuevo',
    'Buen estado',
    'Para reparar',
  ];

  @override
  void initState() {
    super.initState();
    _restaurarFiltros();
    _cargarCategorias();
  }

  // Recupera los filtros anteriores.
  void _restaurarFiltros() {
    final filtros = widget.filtrosActuales;

    if (filtros == null) return;

    final categorias = filtros['categorias'];
    if (categorias is List) {
      _categoriasSeleccionadas.addAll(categorias.map((e) => e.toString()));
    }

    final estados = filtros['estados'];
    if (estados is List) {
      _estadosSeleccionados.addAll(estados.map((e) => e.toString()));
    }

    final precioMin = filtros['precioMin'];
    final precioMax = filtros['precioMax'];

    if (precioMin is num && precioMax is num) {
      final minimo = precioMin.toDouble().clamp(0.0, 20000.0).toDouble();
      final maximo = precioMax.toDouble().clamp(0.0, 20000.0).toDouble();

      _precio = RangeValues(
        minimo <= maximo ? minimo : maximo,
        minimo <= maximo ? maximo : minimo,
      );
    }
  }

  // Carga las categorías activas desde SQLite.
  Future<void> _cargarCategorias() async {
    try {
      final db = await BaseDatos.instance.database;

      final resultado = await db.query(
        'categorias',
        columns: ['nombre'],
        where: 'activa = ?',
        whereArgs: [1],
        orderBy: 'nombre COLLATE NOCASE ASC',
      );

      final categorias = resultado
          .map((fila) => fila['nombre'].toString())
          .toList();

      if (!mounted) return;

      setState(() {
        _categoriasDisponibles = categorias;

        // Quita las categorías que fueron desactivadas.
        _categoriasSeleccionadas.removeWhere(
          (categoria) => !categorias.contains(categoria),
        );

        _cargandoCategorias = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoCategorias = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar categorías: $e'),
          backgroundColor: DaleColores.verdeBosque,
        ),
      );
    }
  }

  // Construye los chips de selección.
  Widget _construirChips(List<String> opciones, Set<String> seleccionadas) {
    if (opciones.isEmpty) {
      return const Text(
        'No hay opciones disponibles.',
        style: TextStyle(color: DaleColores.grisMusgo),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: opciones.map((opcion) {
        final seleccionado = seleccionadas.contains(opcion);

        return FilterChip(
          label: Text(opcion),
          selected: seleccionado,

          onSelected: (valor) {
            setState(() {
              if (valor) {
                seleccionadas.add(opcion);
              } else {
                seleccionadas.remove(opcion);
              }
            });
          },

          selectedColor: DaleColores.verdeLima,
          checkmarkColor: DaleColores.verdeBosque,
          backgroundColor: DaleColores.blanco,

          side: BorderSide(
            color: seleccionado ? DaleColores.verdeBosque : DaleColores.borde,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          labelStyle: TextStyle(
            color: seleccionado ? DaleColores.verdeBosque : DaleColores.carbon,
            fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  // Limpia los filtros.
  void _limpiarFiltros() {
    setState(() {
      _categoriasSeleccionadas.clear();
      _estadosSeleccionados.clear();
      _precio = const RangeValues(0, 20000);
    });
  }

  // Devuelve los filtros a BuscarScreen.
  void _aplicarFiltros() {
    Navigator.pop(context, {
      'categorias': _categoriasSeleccionadas.toList(),
      'estados': _estadosSeleccionados.toList(),
      'precioMin': _precio.start,
      'precioMax': _precio.end,
    });
  }

  // Encabezado de cada sección.
  Widget _tituloSeccion(String titulo, String descripcion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DaleColores.carbon,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          descripcion,
          style: const TextStyle(fontSize: 13, color: DaleColores.grisMusgo),
        ),
      ],
    );
  }

  // Contenedor visual para cada sección.
  Widget _tarjetaSeccion({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DaleColores.blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: DaleColores.carbon.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,

      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        foregroundColor: DaleColores.carbon,
        elevation: 0,

        title: const Text(
          'Filtros',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: DaleColores.carbon,
          ),
        ),

        actions: [
          TextButton(
            onPressed: _limpiarFiltros,
            child: const Text(
              'Limpiar',
              style: TextStyle(
                color: DaleColores.verdeBosque,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            // CATEGORÍAS
            _tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tituloSeccion(
                    'Categorías',
                    'Selecciona una o varias categorías.',
                  ),
                  const SizedBox(height: 18),

                  if (_cargandoCategorias)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: DaleColores.verdeBosque,
                        ),
                      ),
                    )
                  else if (_categoriasDisponibles.isEmpty)
                    const Text(
                      'No hay categorías activas registradas.',
                      style: TextStyle(color: DaleColores.grisMusgo),
                    )
                  else
                    _construirChips(
                      _categoriasDisponibles,
                      _categoriasSeleccionadas,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRECIO
            _tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tituloSeccion(
                    'Rango de precio',
                    'Establece cuánto deseas gastar.',
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _precioTexto(_precio.start),
                      _precioTexto(_precio.end),
                    ],
                  ),

                  RangeSlider(
                    values: _precio,
                    min: 0,
                    max: 20000,
                    divisions: 200,
                    activeColor: DaleColores.verdeBosque,
                    inactiveColor: DaleColores.verdeLima,

                    labels: RangeLabels(
                      '\$${_precio.start.toStringAsFixed(0)}',
                      '\$${_precio.end.toStringAsFixed(0)}',
                    ),

                    onChanged: (valores) {
                      setState(() {
                        _precio = valores;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ESTADO DEL PRODUCTO
            _tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tituloSeccion(
                    'Estado del producto',
                    'Selecciona el estado que estás buscando.',
                  ),

                  const SizedBox(height: 18),

                  _construirChips(_estadosDisponibles, _estadosSeleccionados),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // BOTÓN APLICAR
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _cargandoCategorias ? null : _aplicarFiltros,

                icon: const Icon(Icons.tune_rounded),

                label: const Text(
                  'Aplicar filtros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                style: FilledButton.styleFrom(
                  backgroundColor: DaleColores.verdeBosque,
                  foregroundColor: DaleColores.blanco,
                  disabledBackgroundColor: DaleColores.grisMusgo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _precioTexto(double precio) {
    return Text(
      '\$${precio.toStringAsFixed(0)}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: DaleColores.verdeBosque,
      ),
    );
  }
}
