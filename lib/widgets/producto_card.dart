import 'package:flutter/material.dart';
import '../screens/producto_detalle_screen.dart';

/// Datos de ejemplo (solo para maquetar, sin backend).
class Producto {
  final String titulo;
  final String descripcion;
  final String precio;
  final String modalidad;
  const Producto(this.titulo, this.descripcion, this.precio, this.modalidad);
}

const productosDemo = [
  Producto('Bicicleta de montaña rodada 26',
      'Buen estado, con factura y número de serie. Col. Centro.', '\$2,500', 'Vender'),
  Producto('Silla de madera',
      'Artesanal, ideal para comedor. Col. San Juan.', 'Gratis', 'Donar'),
  Producto('Audífonos inalámbricos',
      'Como nuevos. Acepto intercambio por libros.', '\$350', 'Intercambiar'),
  Producto('Uniforme escolar talla M',
      'Poco uso, lavado y planchado.', '\$150', 'Vender'),
];

class ProductoCard extends StatelessWidget {
  final Producto producto;
  const ProductoCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProductoDetalleScreen(producto: producto),
        )),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                color: cs.surfaceContainerHighest,
                child: const Icon(Icons.image_outlined, size: 36),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto.titulo,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(producto.descripcion,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Chip(
                          label: Text(producto.modalidad),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Spacer(),
                        Text(producto.precio,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
