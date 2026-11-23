import 'package:flutter/material.dart';

import '../widgets/producto_card.dart';
import '../widgets/estilo_app.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  Color _colorModalidad() {
    switch (producto.modalidad.toLowerCase()) {
      case 'donar':
        return DaleColores.verdeBosque;
      case 'subastar':
        return DaleColores.ambar;
      case 'intercambiar':
        return const Color(0xFF668A9A);
      default:
        return DaleColores.verdeClaro;
    }
  }

  IconData _iconoProducto() {
    final titulo = producto.titulo.toLowerCase();

    if (titulo.contains('bicicleta')) {
      return Icons.directions_bike_rounded;
    }
    if (titulo.contains('silla') || titulo.contains('mueble')) {
      return Icons.chair_alt_rounded;
    }
    if (titulo.contains('audífonos')) {
      return Icons.headphones_rounded;
    }
    if (titulo.contains('uniforme') || titulo.contains('ropa')) {
      return Icons.checkroom_rounded;
    }

    return Icons.recycling_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorModalidad = _colorModalidad();

    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Detalle del producto',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Imagen provisional
          Container(
            height: 250,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DaleColores.verdeLima.withOpacity(0.35),
                  DaleColores.verdeLima.withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: DaleColores.borde),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 18,
                  right: 20,
                  child: Icon(
                    Icons.eco_outlined,
                    size: 65,
                    color: Color(0x553D7050),
                  ),
                ),
                const Positioned(
                  bottom: 18,
                  left: 20,
                  child: Icon(
                    Icons.autorenew_rounded,
                    size: 48,
                    color: Color(0x443D7050),
                  ),
                ),
                Center(
                  child: Icon(
                    _iconoProducto(),
                    size: 100,
                    color: DaleColores.verdeBosque,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colorModalidad.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    producto.modalidad,
                    style: TextStyle(
                      color: colorModalidad,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  producto.titulo,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: DaleColores.carbon,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  producto.precio,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: DaleColores.verdeBosque,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: DaleColores.carbon,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 7),

                Text(
                  producto.descripcion,
                  style: const TextStyle(
                    color: DaleColores.grisMusgo,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Información del producto',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: DaleColores.carbon,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 10),

                _informacionCard(
                  icono: Icons.verified_outlined,
                  titulo: 'Evidencia de propiedad',
                  detalle: 'Número de serie y factura',
                  color: DaleColores.verdeBosque,
                ),

                const SizedBox(height: 10),

                _informacionCard(
                  icono: Icons.person_outline_rounded,
                  titulo: 'Vendedor',
                  detalle: 'Eco-puntos: 120',
                  color: DaleColores.ambar,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text(
                      'Contactar por chat',
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
          ),
        ],
      ),
    );
  }

  Widget _informacionCard({
    required IconData icono,
    required String titulo,
    required String detalle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: DaleColores.carbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detalle,
                  style: const TextStyle(
                    color: DaleColores.grisMusgo,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
