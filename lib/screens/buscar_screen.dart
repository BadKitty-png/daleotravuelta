import 'package:flutter/material.dart';

import '../database/base_datos.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/producto_card.dart';
import '../widgets/estilo_app.dart';
import 'filtros_screen.dart';

/// Pantalla de búsqueda conectada a SQLite y filtros avanzados.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  // Categorías obtenidas de la base de datos.
  List<String> _categoriasDisponibles = [];

  // Búsqueda y categoría rápida.
  String _texto = '';
  String _categoria = 'Todo';

  // Publicaciones.
  List<Producto> _productos = [];

  bool _cargando = true;
  bool _cargandoCategorias = true;

  String? _error;
  String? _errorCategorias;

  // Filtros avanzados.
  Map<String, dynamic> _filtrosAplicados = {
    'categorias': <String>[],
    'estados': <String>[],
    'precioMin': 0.0,
    'precioMax': 20000.0,
  };

  @override
  void initState() {
    super.initState();
    _actualizarDatos();
  }

  // =====================================================
  // ACTUALIZAR INFORMACIÓN
  // =====================================================

  Future<void> _actualizarDatos() async {
    await _cargarCategorias();
    await _cargarProductos();
  }

  // =====================================================
  // CARGAR CATEGORÍAS DESDE SQLITE
  // =====================================================

  Future<void> _cargarCategorias() async {
    if (mounted) {
      setState(() {
        _cargandoCategorias = true;
        _errorCategorias = null;
      });
    }

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
          .where((nombre) => nombre.trim().isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _categoriasDisponibles = categorias;

        // Si la categoría seleccionada fue desactivada,
        // regresar a Todo.
        if (_categoria != 'Todo' &&
            !_categoriasDisponibles.contains(_categoria)) {
          _categoria = 'Todo';
        }

        _cargandoCategorias = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoCategorias = false;
        _errorCategorias = 'No se pudieron cargar las categorías.';
      });

      debugPrint('Error al cargar categorías: $e');
    }
  }

  // =====================================================
  // CARGAR PUBLICACIONES Y APLICAR FILTROS EN SQLITE
  // =====================================================

  Future<void> _cargarProductos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final db = await BaseDatos.instance.database;

      final List<String> condiciones = ['estado_publicacion = ?'];

      final List<dynamic> argumentos = ['activa'];

      // -------------------------------------------------
      // FILTRO DE PRECIO
      // -------------------------------------------------

      final double precioMin =
          (_filtrosAplicados['precioMin'] as num?)?.toDouble() ?? 0;

      final double precioMax =
          (_filtrosAplicados['precioMax'] as num?)?.toDouble() ?? 20000;

      condiciones.add('precio >= ? AND precio <= ?');

      argumentos.add(precioMin);
      argumentos.add(precioMax);

      // -------------------------------------------------
      // FILTRO DE ESTADO DEL PRODUCTO
      // -------------------------------------------------

      final List<String> estados = List<String>.from(
        _filtrosAplicados['estados'] ?? [],
      );

      if (estados.isNotEmpty) {
        final marcadores = List.filled(estados.length, '?').join(', ');

        condiciones.add('estado_producto IN ($marcadores)');
        argumentos.addAll(estados);
      }

      // -------------------------------------------------
      // FILTRO DE CATEGORÍAS AVANZADAS
      // -------------------------------------------------

      final List<String> categoriasFiltro = List<String>.from(
        _filtrosAplicados['categorias'] ?? [],
      );

      if (categoriasFiltro.isNotEmpty) {
        final marcadores = List.filled(categoriasFiltro.length, '?').join(', ');

        // Todas las categorías se comparan por su nombre exacto.
        // "Otros productos" también es una categoría normal.
        condiciones.add('categoria IN ($marcadores)');
        argumentos.addAll(categoriasFiltro);
      }

      // -------------------------------------------------
      // CONSULTA A SQLITE
      // -------------------------------------------------

      final datos = await db.query(
        'publicaciones',
        where: condiciones.join(' AND '),
        whereArgs: argumentos,
        orderBy: 'fecha_creacion DESC',
      );

      final productos = datos.map((fila) => Producto.desdeMapa(fila)).toList();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar las publicaciones.';
      });

      debugPrint('Error al cargar publicaciones: $e');
    }
  }

  // =====================================================
  // ABRIR FILTROS AVANZADOS
  // =====================================================

  Future<void> _abrirFiltros() async {
    final resultado = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => FiltrosScreen(filtrosActuales: _filtrosAplicados),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      _filtrosAplicados = resultado;
    });

    await _cargarProductos();
  }

  // =====================================================
  // ESTADO DE LOS FILTROS
  // =====================================================

  bool get _hayFiltrosActivos {
    final categorias = List<String>.from(_filtrosAplicados['categorias'] ?? []);

    final estados = List<String>.from(_filtrosAplicados['estados'] ?? []);

    final precioMin = (_filtrosAplicados['precioMin'] as num?)?.toDouble() ?? 0;

    final precioMax =
        (_filtrosAplicados['precioMax'] as num?)?.toDouble() ?? 20000;

    return categorias.isNotEmpty ||
        estados.isNotEmpty ||
        precioMin > 0 ||
        precioMax < 20000;
  }

  // =====================================================
  // FILTRAR RESULTADOS EN PANTALLA
  // =====================================================

  List<Producto> get _resultados {
    return _productos.where((producto) {
      final titulo = producto.titulo.toLowerCase();
      final descripcion = producto.descripcion.toLowerCase();

      final categoriaProducto = producto.categoria.trim().toLowerCase();

      final textoBusqueda = _texto.toLowerCase();

      // Búsqueda por título y descripción.
      final okTexto =
          textoBusqueda.isEmpty ||
          titulo.contains(textoBusqueda) ||
          descripcion.contains(textoBusqueda);

      // Categoría rápida: comparación exacta.
      // No se utilizan categorías inventadas ni equivalencias.
      final okCategoria =
          _categoria == 'Todo' ||
          categoriaProducto == _categoria.trim().toLowerCase();

      return okTexto && okCategoria;
    }).toList();
  }

  // =====================================================
  // CONSTRUIR CATEGORÍAS RÁPIDAS
  // =====================================================

  Widget _construirCategorias() {
    if (_cargandoCategorias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(color: DaleColores.verdeBosque),
        ),
      );
    }

    if (_errorCategorias != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _errorCategorias!,
          style: const TextStyle(
            color: DaleColores.grisMusgo,
            fontFamily: 'Roboto',
          ),
        ),
      );
    }

    // Todo siempre está disponible.
    final categorias = ['Todo', ..._categoriasDisponibles];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final categoria in categorias)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria),
                selected: _categoria == categoria,

                onSelected: (_) {
                  setState(() {
                    _categoria = categoria;
                  });
                },

                selectedColor: DaleColores.verdeBosque,
                backgroundColor: DaleColores.blanco,
                checkmarkColor: DaleColores.blanco,

                labelStyle: TextStyle(
                  color: _categoria == categoria
                      ? DaleColores.blanco
                      : DaleColores.grisMusgo,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),

                side: BorderSide(
                  color: _categoria == categoria
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
    );
  }

  // =====================================================
  // INTERFAZ
  // =====================================================

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

      body: RefreshIndicator(
        onRefresh: _actualizarDatos,
        color: DaleColores.verdeBosque,

        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),

          children: [
            // ===========================================
            // ENCABEZADO VISUAL
            // ===========================================

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

            // ===========================================
            // BUSCADOR Y FILTROS
            // ===========================================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (valor) {
                      setState(() {
                        _texto = valor.trim();
                      });
                    },

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
                      fillColor: DaleColores.blanco,

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

                Stack(
                  clipBehavior: Clip.none,
                  children: [
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

                        icon: const Icon(
                          Icons.tune_rounded,
                          color: DaleColores.blanco,
                        ),

                        onPressed: _abrirFiltros,
                      ),
                    ),

                    if (_hayFiltrosActivos)
                      Positioned(
                        top: -4,
                        right: -4,

                        child: Container(
                          width: 13,
                          height: 13,

                          decoration: BoxDecoration(
                            color: DaleColores.verdeLima,
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: DaleColores.crema,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ===========================================
            // CATEGORÍAS DINÁMICAS
            // ===========================================
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

            _construirCategorias(),

            const SizedBox(height: 20),

            // ===========================================
            // RESULTADOS
            // ===========================================
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

            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(
                    color: DaleColores.verdeBosque,
                  ),
                ),
              )
            else if (_error != null)
              EstadoVacio(
                mensaje: 'Ocurrió un error',
                detalle: _error!,
                icono: Icons.error_outline,
              )
            else if (resultados.isEmpty)
              const EstadoVacio(
                mensaje: 'No hay elementos',
                detalle: 'Prueba con otra búsqueda o cambia los filtros.',
                icono: Icons.search_off,
              )
            else
              for (final producto in resultados)
                ProductoCard(producto: producto),
          ],
        ),
      ),
    );
  }
}
