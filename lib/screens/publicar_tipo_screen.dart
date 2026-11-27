import 'package:flutter/material.dart';

import '../database/base_datos.dart';
import '../widgets/estilo_app.dart';
import 'publicar_datos_screen.dart';

class PublicarTipoScreen extends StatefulWidget {
  const PublicarTipoScreen({super.key});

  @override
  State<PublicarTipoScreen> createState() => _PublicarTipoScreenState();
}

class _PublicarTipoScreenState extends State<PublicarTipoScreen> {
  String _modalidad = 'Donar';

  List<String> _categorias = [];
  String? _categoria;

  bool _cargandoCategorias = true;
  String? _errorCategorias;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  // Obtener las categorías activas desde SQLite.
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
        _categorias = categorias;

        if (_categorias.isNotEmpty) {
          if (!_categorias.contains(_categoria)) {
            _categoria = _categorias.first;
          }
        } else {
          _categoria = null;
        }

        _cargandoCategorias = false;
        _errorCategorias = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoCategorias = false;
        _errorCategorias = 'No se pudieron cargar las categorías.';
      });
    }
  }

  Color _colorModalidad(String modalidad) {
    switch (modalidad) {
      case 'Donar':
        return DaleColores.verdeBosque;
      case 'Vender':
        return DaleColores.verdeClaro;
      default:
        return DaleColores.ambar;
    }
  }

  IconData _iconoModalidad(String modalidad) {
    switch (modalidad) {
      case 'Vender':
        return Icons.sell_outlined;
      case 'Donar':
        return Icons.volunteer_activism_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Publicar un objeto',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _encabezado(),
          const SizedBox(height: 24),

          const Text(
            '¿Qué quieres hacer?',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige cómo quieres darle una nueva vuelta a tu objeto.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 14),

          for (final modalidad in ['Vender', 'Donar', 'Intercambiar'])
            _tarjetaModalidad(modalidad),

          const SizedBox(height: 24),

          const Text(
            'Categoría del objeto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 10),

          _construirSelectorCategorias(),

          const SizedBox(height: 30),

          _boton(
            texto: 'Continuar',
            icono: Icons.arrow_forward_rounded,
            onPressed: _categoria == null || _cargandoCategorias
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PublicarDatosScreen(
                          categoria: _categoria!,
                          modalidad: _modalidad,
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  // Selector conectado a la tabla categorias.
  Widget _construirSelectorCategorias() {
    if (_cargandoCategorias) {
      return Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DaleColores.borde),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 19,
              width: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DaleColores.verdeBosque,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Cargando categorías...',
              style: TextStyle(
                color: DaleColores.grisMusgo,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      );
    }

    if (_errorCategorias != null) {
      return _mensajeCategorias(
        icono: Icons.error_outline_rounded,
        mensaje: _errorCategorias!,
        accion: 'Reintentar',
        onPressed: _cargarCategorias,
      );
    }

    if (_categorias.isEmpty) {
      return _mensajeCategorias(
        icono: Icons.category_outlined,
        mensaje: 'No hay categorías disponibles.',
        accion: 'Actualizar',
        onPressed: _cargarCategorias,
      );
    }

    return DropdownButtonFormField<String>(
      key: ValueKey(_categoria),
      initialValue: _categoria,
      isExpanded: true,
      decoration: _decoracion(
        'Selecciona una categoría',
        Icons.category_outlined,
      ),
      items: _categorias.map((categoria) {
        return DropdownMenuItem(
          value: categoria,
          child: Text(categoria, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (valor) {
        if (valor != null) {
          setState(() => _categoria = valor);
        }
      },
    );
  }

  Widget _mensajeCategorias({
    required IconData icono,
    required String mensaje,
    required String accion,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Row(
        children: [
          Icon(icono, color: DaleColores.verdeBosque),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: DaleColores.grisMusgo,
                fontSize: 12,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              accion,
              style: const TextStyle(
                color: DaleColores.verdeBosque,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
                      'Publica y comparte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ayuda a que un objeto encuentre un nuevo hogar.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const LogoDaleVuelta(size: 62),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaModalidad(String modalidad) {
    final seleccionada = _modalidad == modalidad;
    final color = _colorModalidad(modalidad);

    return GestureDetector(
      onTap: () => setState(() => _modalidad = modalidad),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionada ? color.withValues(alpha: 0.09) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: seleccionada ? color : DaleColores.borde,
            width: seleccionada ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconoModalidad(modalidad), color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                modalidad,
                style: const TextStyle(
                  color: DaleColores.carbon,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Icon(
              seleccionada ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: seleccionada ? color : DaleColores.grisMusgo,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracion(String texto, IconData icono) {
    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono, color: DaleColores.verdeBosque),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: DaleColores.verdeBosque,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _boton({
    required String texto,
    required IconData icono,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono),
        label: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: DaleColores.verdeBosque,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DaleColores.grisMusgo.withValues(alpha: 0.3),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
