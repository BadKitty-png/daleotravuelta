import 'package:flutter/material.dart';

import '../screens/producto_detalle_screen.dart';
import 'estilo_app.dart';

/// Datos de ejemplo (solo para maquetar, sin backend).
class Producto {
  final String titulo;
  final String descripcion;
  final String precio;
  final String modalidad;

  const Producto(this.titulo, this.descripcion, this.precio, this.modalidad);
}

const productosDemo = [
  Producto(
    'Bicicleta de montaña rodada 26',
    'Buen estado, con factura y número de serie. Col. Centro.',
    '\$2,500',
    'Vender',
  ),
  Producto(
    'Silla de madera',
    'Artesanal, ideal para comedor. Col. San Juan.',
    'Gratis',
    'Donar',
  ),
  Producto(
    'Audífonos inalámbricos',
    'Como nuevos. Acepto intercambio por libros.',
    '\$350',
    'Intercambiar',
  ),
  Producto(
    'Uniforme escolar talla M',
    'Poco uso, lavado y planchado.',
    '\$150',
    'Vender',
  ),
];

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

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
    if (titulo.contains('audífonos') || titulo.contains('tecnología')) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: DaleColores.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: DaleColores.carbon.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductoDetalleScreen(producto: producto),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen provisional del producto
                Container(
                  width: 94,
                  height: 100,
                  decoration: BoxDecoration(
                    color: DaleColores.verdeLima.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 6,
                        right: 7,
                        child: Icon(
                          Icons.eco_outlined,
                          size: 19,
                          color: DaleColores.verdeBosque.withOpacity(0.35),
                        ),
                      ),
                      Icon(
                        _iconoProducto(),
                        size: 42,
                        color: DaleColores.verdeBosque,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DaleColores.carbon,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        producto.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DaleColores.grisMusgo,
                          fontSize: 12,
                          height: 1.3,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorModalidad.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                producto.modalidad,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorModalidad,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              producto.precio,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: DaleColores.verdeBosque,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
