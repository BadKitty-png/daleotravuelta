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

          // Campos dinámicos.
          for (final campo in campos) ...[
            _campo(
              etiqueta: campo['nombre']!,
              icono: campo['icono']!,
              tipo: campo['tipo'] == 'numero'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
            const SizedBox(height: 14),
          ],

          // La talla solamente corresponde a bicicletas.
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
            maxLines: 4,
            decoration: _decoracion(
              'Describe las características de tu objeto',
              Icons.description_outlined,
            ).copyWith(alignLabelWithHint: true),
          ),

          const SizedBox(height: 16),

          _campo(etiqueta: 'Número de serie (opcional)', icono: 'serial'),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicarPrecioScreen(),
                  ),
                );
              },
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

  // Bicicletas conserva sus campos particulares.
  // Las demás categorías utilizan un formulario genérico.
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
      keyboardType: tipo,
      decoration: _decoracion(
        etiqueta,
        iconos[icono] ?? Icons.inventory_2_outlined,
      ),
    );
  }
}
