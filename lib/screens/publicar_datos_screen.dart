import 'package:flutter/material.dart';

import '../widgets/estilo_app.dart';
import 'publicar_precio_screen.dart';

class PublicarDatosScreen extends StatefulWidget {
  final String categoria;
  final String modalidad;

  const PublicarDatosScreen({
    super.key,
    required this.categoria,
    required this.modalidad,
  });

  @override
  State<PublicarDatosScreen> createState() => _PublicarDatosScreenState();
}

class _PublicarDatosScreenState extends State<PublicarDatosScreen> {
  String _talla = 'M';
  String _estado = 'Buen estado';

  final _tituloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroSerieController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _caracteristicasController.dispose();
    _descripcionController.dispose();
    _numeroSerieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campos = _obtenerCampos();

    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Datos del producto',
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
            'Cuéntanos sobre tu objeto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Completa los datos de tu objeto de la categoría ${widget.categoria.toLowerCase()}.',
            style: const TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 20),

          for (final campo in campos) ...[
            _campo(
              etiqueta: campo['nombre']!,
              icono: campo['icono']!,
              controller: _obtenerControlador(campo['icono']!),
              tipo: campo['tipo'] == 'numero'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
            const SizedBox(height: 14),
          ],

          if (widget.categoria == 'Bicicletas') ...[
            const Text(
              'Talla de la bicicleta',
              style: TextStyle(
                color: DaleColores.carbon,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 10),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'S', label: Text('S')),
                ButtonSegment(value: 'M', label: Text('M')),
                ButtonSegment(value: 'X', label: Text('X')),
              ],
              selected: {_talla},
              onSelectionChanged: (s) {
                setState(() => _talla = s.first);
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : DaleColores.verdeBosque,
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? DaleColores.verdeBosque
                      : Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 22),
          ],

          const Text(
            'Estado del producto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in ['Buen estado', 'Como nueva', 'Para reparar'])
                ChoiceChip(
                  label: Text(e),
                  selected: _estado == e,
                  onSelected: (_) => setState(() => _estado = e),
                  selectedColor: DaleColores.verdeBosque,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _estado == e ? Colors.white : DaleColores.grisMusgo,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                  side: BorderSide(
                    color: _estado == e
                        ? DaleColores.verdeBosque
                        : DaleColores.borde,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Descripción',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 9),

          TextField(
            controller: _descripcionController,
            maxLines: 4,
            decoration: _decoracion(
              'Describe las características de tu objeto',
              Icons.description_outlined,
            ).copyWith(alignLabelWithHint: true),
          ),

          const SizedBox(height: 16),

          _campo(
            etiqueta: 'Número de serie (opcional)',
            icono: 'serial',
            controller: _numeroSerieController,
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _continuar,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'Siguiente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DaleColores.verdeBosque,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _continuar() {
    final descripcion = _descripcionController.text.trim();

    if (widget.categoria != 'Bicicletas' &&
        _tituloController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe el nombre del producto.');
      return;
    }

    if (descripcion.isEmpty) {
      _mostrarMensaje('Escribe una descripción del producto.');
      return;
    }

    final titulo = widget.categoria == 'Bicicletas'
        ? 'Bicicleta ${_marcaController.text.trim()} ${_modeloController.text.trim()}'
              .trim()
        : _tituloController.text.trim();

    final anioTexto = _anioController.text.trim();
    final anio = int.tryParse(anioTexto);

    if (anioTexto.isNotEmpty && anio == null) {
      _mostrarMensaje('El año debe ser un número válido.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicarPrecioScreen(
          categoria: widget.categoria,
          modalidad: widget.modalidad,
          titulo: titulo,
          marca: _marcaController.text.trim(),
          modelo: _modeloController.text.trim(),
          anio: anio,
          talla: widget.categoria == 'Bicicletas' ? _talla : null,
          estadoProducto: _estado,
          descripcion: descripcion,
          numeroSerie: _numeroSerieController.text.trim(),
          caracteristicas: _caracteristicasController.text.trim(),
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  List<Map<String, String>> _obtenerCampos() {
    if (widget.categoria == 'Bicicletas') {
      return [
        {'nombre': 'Marca de la bicicleta', 'icono': 'marca'},
        {'nombre': 'Año', 'icono': 'calendar', 'tipo': 'numero'},
        {'nombre': 'Modelo', 'icono': 'model'},
      ];
    }

    return [
      {'nombre': 'Nombre del producto', 'icono': 'producto'},
      {'nombre': 'Marca (opcional)', 'icono': 'marca'},
      {'nombre': 'Modelo o referencia (opcional)', 'icono': 'model'},
      {
        'nombre': 'Material, dimensiones o características',
        'icono': 'caracteristicas',
      },
    ];
  }

  TextEditingController _obtenerControlador(String icono) {
    switch (icono) {
      case 'marca':
        return _marcaController;
      case 'calendar':
        return _anioController;
      case 'model':
        return _modeloController;
      case 'producto':
        return _tituloController;
      case 'caracteristicas':
        return _caracteristicasController;
      default:
        return _tituloController;
    }
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles que importan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${widget.categoria} · ${widget.modalidad}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Completa la información de tu publicación.',
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

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
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

  Widget _campo({
    required String etiqueta,
    required String icono,
    required TextEditingController controller,
    TextInputType tipo = TextInputType.text,
  }) {
    final iconos = <String, IconData>{
      'marca': Icons.sell_outlined,
      'calendar': Icons.calendar_today_outlined,
      'model': Icons.widgets_outlined,
      'producto': Icons.inventory_2_outlined,
      'caracteristicas': Icons.straighten_outlined,
      'serial': Icons.qr_code_rounded,
    };

    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: _decoracion(
        etiqueta,
        iconos[icono] ?? Icons.inventory_2_outlined,
      ),
    );
  }
}
