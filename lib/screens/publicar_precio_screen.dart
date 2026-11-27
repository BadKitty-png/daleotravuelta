import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../widgets/estilo_app.dart';
import '../models/sesion.dart';
import '../services/publicacion_service.dart';
import 'seleccionar_ubicacion_screen.dart';

/// Pantalla 3 — Precio y ubicación.
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
  final List<String> imagenesTemporales;

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
    required this.imagenesTemporales,
  });

  @override
  State<PublicarPrecioScreen> createState() => _PublicarPrecioScreenState();
}

class _PublicarPrecioScreenState extends State<PublicarPrecioScreen> {
  bool _acepto = false;
  bool _guardando = false;
  bool _obteniendoUbicacion = false;
  bool _zonaDetectada = false;

  final TextEditingController _precioController = TextEditingController();

  final TextEditingController _coloniaController = TextEditingController();

  @override
  void dispose() {
    _precioController.dispose();
    _coloniaController.dispose();
    super.dispose();
  }

  // =========================================================
  // SOLICITAR PERMISOS DE UBICACIÓN
  // =========================================================

  Future<bool> _solicitarPermisoUbicacion() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();

    if (!servicioActivo) {
      _mostrarMensaje(
        'Activa la ubicación de tu dispositivo para detectar tu zona.',
      );
      return false;
    }

    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever) {
      if (!mounted) return false;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Permiso de ubicación'),
            content: const Text(
              'El permiso de ubicación está bloqueado. '
              'Puedes habilitarlo desde los ajustes de la aplicación '
              'o continuar escribiendo tu colonia manualmente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Ahora no'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await Geolocator.openAppSettings();
                },
                child: const Text('Abrir ajustes'),
              ),
            ],
          );
        },
      );

      return false;
    }

    if (permiso == LocationPermission.denied) {
      _mostrarMensaje(
        'No se concedió el permiso. Puedes indicar tu colonia manualmente.',
      );
      return false;
    }

    return permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always;
  }

  // =========================================================
  // DETECTAR COLONIA AUTOMÁTICAMENTE
  // =========================================================

  Future<void> _obtenerUbicacion() async {
    if (_obteniendoUbicacion) return;

    setState(() {
      _obteniendoUbicacion = true;
    });

    try {
      final permisoConcedido = await _solicitarPermisoUbicacion();

      if (!permisoConcedido) return;

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 25),
        ),
      );

      String zona = '';

      try {
        // La función placemarkFromCoordinates es estática.
        // No se debe crear una instancia de Geocoding().
        final lugares = await geo.placemarkFromCoordinates(
          posicion.latitude,
          posicion.longitude,
        );

        if (lugares.isNotEmpty) {
          final lugar = lugares.first;

          zona = lugar.subLocality?.trim() ?? '';

          if (zona.isEmpty) {
            zona = lugar.locality?.trim() ?? '';
          }

          if (zona.isEmpty) {
            zona = lugar.subAdministrativeArea?.trim() ?? '';
          }
        }
      } catch (_) {
        zona = '';
      }

      if (!mounted) return;

      if (zona.isEmpty) {
        _mostrarMensaje(
          'No se pudo identificar tu colonia. Escríbela manualmente.',
        );
        return;
      }

      setState(() {
        _coloniaController.text = zona;
        _zonaDetectada = true;
      });

      _mostrarMensaje('Zona aproximada identificada. Puedes modificarla.');
    } on LocationServiceDisabledException {
      _mostrarMensaje('Activa la ubicación de tu dispositivo.');
    } on PermissionDeniedException {
      _mostrarMensaje('No se concedió el permiso de ubicación.');
    } catch (e) {
      _mostrarMensaje('No se pudo obtener la ubicación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _obteniendoUbicacion = false;
        });
      }
    }
  }

  // =========================================================
  // SELECCIONAR UBICACIÓN EN EL MAPA
  // =========================================================

  Future<void> _seleccionarEnMapa() async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionarUbicacionScreen(),
      ),
    );

    if (!mounted || resultado == null || resultado.trim().isEmpty) {
      return;
    }

    setState(() {
      _coloniaController.text = resultado.trim();
      _zonaDetectada = true;
    });

    _mostrarMensaje('Zona seleccionada correctamente.');
  }

  // =========================================================
  // BORRAR UBICACIÓN
  // =========================================================

  void _quitarUbicacion() {
    setState(() {
      _coloniaController.clear();
      _zonaDetectada = false;
    });
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // =========================================================
  // GUARDAR PUBLICACIÓN
  // =========================================================

  Future<void> _guardarPublicacion() async {
    if (_guardando) return;

    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      _mostrarMensaje(
        'Debes iniciar sesión con una cuenta de usuario para publicar.',
      );
      return;
    }

    double precio = 0;

    if (widget.modalidad == 'Vender') {
      precio =
          double.tryParse(_precioController.text.trim().replaceAll(',', '.')) ??
          0;

      if (precio <= 0) {
        _mostrarMensaje('Ingresa un precio válido mayor que cero.');
        return;
      }
    }

    final coloniaSeleccionada = _coloniaController.text.trim();

    setState(() {
      _guardando = true;
    });

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
        colonia: coloniaSeleccionada,
        municipio: Sesion.municipio,
        rutasImagenesTemporales: widget.imagenesTemporales,
      );

      if (!mounted) return;

      _mostrarMensaje('¡Tu publicación se guardó correctamente!');

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo guardar la publicación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =========================================================
  // INTERFAZ PRINCIPAL
  // =========================================================

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

          if (widget.modalidad == 'Vender') ...[
            TextField(
              controller: _precioController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                onChanged: (valor) {
                  setState(() {
                    _acepto = valor;
                  });
                },
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DaleColores.borde),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volunteer_activism_rounded,
                    color: DaleColores.verdeBosque,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.modalidad == 'Donar'
                          ? 'Este objeto será publicado gratuitamente.'
                          : 'El precio se acordará mediante intercambio.',
                      style: const TextStyle(
                        color: DaleColores.grisMusgo,
                        fontSize: 13,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
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
            'Indica la colonia o zona aproximada donde se encuentra tu objeto.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 12),

          _tarjetaUbicacion(),

          const SizedBox(height: 14),

          // Campo para escribir o modificar la colonia.
          TextField(
            controller: _coloniaController,
            textCapitalization: TextCapitalization.words,
            onChanged: (valor) {
              setState(() {
                _zonaDetectada = false;
              });
            },
            decoration: InputDecoration(
              labelText: 'Colonia o zona cercana',
              hintText: 'Ej. Centro, San Juan, Las Américas...',
              prefixIcon: const Icon(
                Icons.location_city_outlined,
                color: DaleColores.verdeBosque,
              ),
              suffixIcon: _coloniaController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Borrar colonia',
                      onPressed: _quitarUbicacion,
                      icon: const Icon(Icons.close),
                    )
                  : null,
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

          const SizedBox(height: 10),

          // Botón para abrir el mapa.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _seleccionarEnMapa,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Seleccionar ubicación en el mapa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: DaleColores.verdeBosque,
                side: const BorderSide(color: DaleColores.verdeBosque),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Tu ubicación es opcional. No guardamos tus coordenadas GPS ni tu dirección exacta; solamente la colonia o zona que indiques.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 11,
              fontFamily: 'Roboto',
            ),
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

  // =========================================================
  // TARJETA DE UBICACIÓN
  // =========================================================

  Widget _tarjetaUbicacion() {
    final tieneZona = _coloniaController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: DaleColores.borde),
      ),
      child: Column(
        children: [
          Icon(
            tieneZona
                ? Icons.location_on_rounded
                : Icons.location_searching_rounded,
            color: DaleColores.verdeBosque,
            size: 42,
          ),

          const SizedBox(height: 8),

          Text(
            tieneZona ? 'Zona identificada' : 'Ubicación aproximada',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: DaleColores.carbon,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 8),

          Text(
            tieneZona
                ? _zonaDetectada
                      ? 'Zona aproximada identificada. Puedes modificarla.'
                      : 'Puedes escribir tu colonia manualmente o seleccionarla en el mapa.'
                : 'Detecta tu zona automáticamente, selecciónala en el mapa o escríbela manualmente.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _obteniendoUbicacion ? null : _obtenerUbicacion,
              icon: _obteniendoUbicacion
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _obteniendoUbicacion
                    ? 'Identificando zona...'
                    : 'Detectar mi colonia automáticamente',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DaleColores.verdeBosque,
                side: const BorderSide(color: DaleColores.verdeBosque),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (tieneZona) ...[
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _quitarUbicacion,
              icon: const Icon(Icons.location_off_outlined, size: 17),
              label: const Text('Borrar zona'),
              style: TextButton.styleFrom(
                foregroundColor: DaleColores.grisMusgo,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // ENCABEZADO
  // =========================================================

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
