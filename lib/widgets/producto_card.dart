import 'dart:io';

import 'package:flutter/material.dart';

import '../screens/producto_detalle_screen.dart';
import 'boton_favorito.dart';
import 'estilo_app.dart';

/// Datos de ejemplo (solo para maquetar, sin backend).

class Producto {
  final String titulo;
  final String descripcion;
  final String precio;
  final String modalidad;
  final int? id;
  final int? usuarioId;
  final String? imagenPortada;
  final String categoria;
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? talla;
  final String estadoProducto;
  final String? numeroSerie;
  final String? caracteristicas;
  final bool aceptaOfertas;
  final String? colonia;
  final String municipio;

  const Producto(
    this.titulo,
    this.descripcion,
    this.precio,
    this.modalidad, {
    this.id,
    this.usuarioId,
    this.imagenPortada,
    this.categoria = '',
    this.marca,
    this.modelo,
    this.anio,
    this.talla,
    this.estadoProducto = '',
    this.numeroSerie,
    this.caracteristicas,
    this.aceptaOfertas = false,
    this.colonia,
    this.municipio = '',
  });

  // Convierte un registro de SQLite en un objeto Producto.
  factory Producto.desdeMapa(Map<String, dynamic> mapa) {
    final modalidad = (mapa['modalidad'] ?? 'Vender').toString();
    final precioDato = mapa['precio'];

    String precioTexto;

    if (modalidad.toLowerCase() == 'donar') {
      precioTexto = 'Gratis';
    } else if (precioDato is num && precioDato % 1 == 0) {
      precioTexto = '\$${precioDato.toInt()}';
    } else {
      precioTexto = '\$${precioDato ?? 0}';
    }

    return Producto(
      (mapa['titulo'] ?? 'Sin título').toString(),
      (mapa['descripcion'] ?? '').toString(),
      precioTexto,
      modalidad,
      id: (mapa['id'] as num?)?.toInt(),
      usuarioId: (mapa['usuario_id'] as num?)?.toInt(),
      imagenPortada: mapa['imagen_portada']?.toString(),
      categoria: (mapa['categoria'] ?? '').toString(),
      marca: mapa['marca']?.toString(),
      modelo: mapa['modelo']?.toString(),
      anio: (mapa['anio'] as num?)?.toInt(),
      talla: mapa['talla']?.toString(),
      estadoProducto: (mapa['estado_producto'] ?? '').toString(),
      numeroSerie: mapa['numero_serie']?.toString(),
      caracteristicas: mapa['caracteristicas']?.toString(),
      aceptaOfertas: mapa['acepta_ofertas'] == 1,
      colonia: mapa['colonia']?.toString(),
      municipio: (mapa['municipio'] ?? '').toString(),
    );
  }
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

class ProductoCard extends StatefulWidget {
  final Producto producto;

  const ProductoCard({super.key, required this.producto});

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  bool _mostrarTodosLosDatos = false;

  Producto get producto => widget.producto;

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

  Widget _construirImagen() {
    final ruta = producto.imagenPortada?.trim();

    if (ruta != null && ruta.isNotEmpty) {
      final archivo = File(ruta);

      if (archivo.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            archivo,
            width: 94,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _construirImagenProvisional(),
          ),
        );
      }
    }

    return _construirImagenProvisional();
  }

  Widget _construirImagenConFavorito() {
    return SizedBox(
      width: 94,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: _construirImagen()),
          Positioned(
            top: 5,
            right: 5,
            child: BotonFavorito(
              publicacionId: producto.id,
              size: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirImagenProvisional() {
    return Container(
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
          Icon(_iconoProducto(), size: 42, color: DaleColores.verdeBosque),
        ],
      ),
    );
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
            child: Column(
              children: [
                Row(
                  children: [
                    // Fotografía de portada o imagen provisional.
                    _construirImagenConFavorito(),

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
                const SizedBox(height: 8),
                const Divider(height: 1, color: DaleColores.borde),
                InkWell(
                  onTap: () => setState(
                    () => _mostrarTodosLosDatos = !_mostrarTodosLosDatos,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _mostrarTodosLosDatos
                              ? 'Ocultar datos'
                              : 'Ver todos los datos',
                          style: const TextStyle(
                            color: DaleColores.verdeBosque,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _mostrarTodosLosDatos
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: DaleColores.verdeBosque,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  child: _mostrarTodosLosDatos
                      ? _construirDatosCompletos()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirDatosCompletos() {
    final ubicacion = [
      producto.colonia,
      producto.municipio,
    ].whereType<String>().where((v) => v.trim().isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dato('Categoría', producto.categoria),
          _dato('Marca', producto.marca),
          _dato('Modelo', producto.modelo),
          _dato('Año', producto.anio?.toString()),
          _dato('Talla', producto.talla),
          _dato('Estado', producto.estadoProducto),
          _dato('Número de serie', producto.numeroSerie),
          _dato('Características', producto.caracteristicas),
          _dato('Ubicación', ubicacion),
          _dato('Acepta ofertas', producto.aceptaOfertas ? 'Sí' : 'No'),
        ],
      ),
    );
  }

  Widget _dato(String etiqueta, String? valor) {
    if (valor == null || valor.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              etiqueta,
              style: const TextStyle(
                color: DaleColores.grisMusgo,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: DaleColores.carbon,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
