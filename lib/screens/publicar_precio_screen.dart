import 'package:flutter/material.dart';

import '../widgets/estilo_app.dart';

import '../models/sesion.dart';
import '../services/publicacion_service.dart'; //Importaciones sobre los nuuevos modulos, migracion de

//publicaciones a la base de datos

/// Pantalla 3 (parte 2) — Precio y ubicación.
class PublicarPrecioScreen extends StatefulWidget {
  final String categoria;
  final String modalidad;
  final String titulo;
  final String marca;
  final String modelo;
  final int? anio;
  final String? talla;
  final String estadoProducto;
  final String descripcion;
  final String numeroSerie;
  final String caracteristicas;

  const PublicarPrecioScreen({
    super.key,
    required this.categoria,
    required this.modalidad,
    required this.titulo,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.talla,
    required this.estadoProducto,
    required this.descripcion,
    required this.numeroSerie,
    required this.caracteristicas,
  });

  @override
  State<PublicarPrecioScreen> createState() => _PublicarPrecioScreenState();
}

class _PublicarPrecioScreenState extends State<PublicarPrecioScreen> {
  bool _acepto = false;

  final List<String> _colonias = [
    'Col. Centro',
    'Col. San Juan',
    'Col. Las Américas',
  ];

  String _colonia = 'Col. Centro';

  final TextEditingController _precioController = TextEditingController();
  //--------------------------
  bool _guardando = false;

  @override //Cambios a base de datos guardado
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  //--------------------------------
  Future<void> _guardarPublicacion() async {
    if (_guardando) return;

    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes iniciar sesión con una cuenta de usuario para publicar.',
          ),
        ),
      );
      return;
    }

    double precio = 0;

    if (widget.modalidad == 'Vender') {
      precio =
          double.tryParse(_precioController.text.trim().replaceAll(',', '.')) ??
          0;

      if (precio <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingresa un precio válido mayor que cero.'),
          ),
        );
        return;
      }
    }

    setState(() => _guardando = true);

    try {
      await PublicacionService.instance.guardarPublicacion(
        usuarioId: usuarioId,
        categoria: widget.categoria,
        modalidad: widget.modalidad,
        titulo: widget.titulo,
        marca: widget.marca.isEmpty ? null : widget.marca,
        modelo: widget.modelo.isEmpty ? null : widget.modelo,
        anio: widget.anio,
        talla: widget.talla,
        estadoProducto: widget.estadoProducto,
        descripcion: widget.descripcion,
        numeroSerie: widget.numeroSerie.isEmpty ? null : widget.numeroSerie,
        caracteristicas: widget.caracteristicas.isEmpty
            ? null
            : widget.caracteristicas,
        aceptaOfertas: widget.modalidad == 'Vender' && _acepto,
        precio: precio,
        colonia: _colonia,
        municipio: Sesion.municipio,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tu publicación se guardó correctamente!'),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la publicación: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  //----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Precio y ubicación',
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
            'Últimos detalles',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Indica el precio y dónde pueden encontrar tu objeto.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Precio del producto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 9),

          TextField(
            controller: _precioController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Precio',
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: DaleColores.verdeBosque,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
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
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DaleColores.borde),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              title: const Text(
                'Acepto ofertas',
                style: TextStyle(
                  color: DaleColores.carbon,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
              subtitle: const Text(
                'Permite que otras personas te propongan un precio.',
                style: TextStyle(
                  color: DaleColores.grisMusgo,
                  fontSize: 11,
                  fontFamily: 'Roboto',
                ),
              ),
              secondary: const Icon(
                Icons.handshake_outlined,
                color: DaleColores.verdeBosque,
              ),
              activeThumbColor: DaleColores.verdeBosque,
              value: _acepto,
              onChanged: (v) => setState(() => _acepto = v),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Ubicación del objeto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona la zona donde se encuentra.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 180,
            decoration: BoxDecoration(
              color: DaleColores.verdeLima.withOpacity(0.22),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: DaleColores.borde),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12,
                  right: 16,
                  child: Icon(
                    Icons.eco_outlined,
                    size: 42,
                    color: DaleColores.verdeBosque.withOpacity(0.25),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Icon(
                    Icons.autorenew_rounded,
                    size: 35,
                    color: DaleColores.verdeBosque.withOpacity(0.25),
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: DaleColores.verdeBosque,
                      size: 48,
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ubicación aproximada',
                      style: TextStyle(
                        color: DaleColores.verdeBosque,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      'Vista previa del mapa',
                      style: TextStyle(
                        color: DaleColores.grisMusgo,
                        fontSize: 11,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            initialValue: _colonia,
            decoration: InputDecoration(
              labelText: 'Colonia',
              prefixIcon: const Icon(
                Icons.location_city_outlined,
                color: DaleColores.verdeBosque,
              ),
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
            ),
            items: _colonias
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (valor) {
              if (valor != null) {
                setState(() => _colonia = valor);
              }
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarPublicacion,
              icon: const Icon(Icons.eco_rounded),
              label: Text(
                _guardando ? 'Guardando...' : 'Publicar objeto',
                style: const TextStyle(
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

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Dale una segunda oportunidad a tus objetos 🌱',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DaleColores.grisMusgo,
                fontSize: 11,
                fontFamily: 'Roboto',
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
                      '¡Ya casi terminas!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Completa la información para compartir tu publicación.',
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
}
