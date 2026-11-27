// TODO Implement this library.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../widgets/estilo_app.dart';

class SeleccionarUbicacionScreen extends StatefulWidget {
  const SeleccionarUbicacionScreen({super.key});

  @override
  State<SeleccionarUbicacionScreen> createState() =>
      _SeleccionarUbicacionScreenState();
}

class _SeleccionarUbicacionScreenState
    extends State<SeleccionarUbicacionScreen> {
  final MapController _mapController = MapController();

  // Centro inicial: Dolores Hidalgo, Guanajuato.
  LatLng _centro = const LatLng(21.1561, -100.9325);

  bool _obteniendoUbicacion = false;
  bool _confirmando = false;

  // =========================================================
  // OBTENER PERMISOS
  // =========================================================

  Future<bool> _solicitarPermiso() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();

    if (!servicioActivo) {
      _mensaje('Activa la ubicación de tu dispositivo.');
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
        builder: (dialogContext) => AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: const Text(
            'El permiso está bloqueado. Puedes activarlo '
            'desde los ajustes de la aplicación o seleccionar '
            'tu ubicación manualmente en el mapa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await Geolocator.openAppSettings();
              },
              child: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );

      return false;
    }

    if (permiso == LocationPermission.denied) {
      _mensaje('No se concedió el permiso de ubicación.');
      return false;
    }

    return permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always;
  }

  // =========================================================
  // CENTRAR MAPA EN MI UBICACIÓN
  // =========================================================

  Future<void> _irAMiUbicacion() async {
    if (_obteniendoUbicacion) return;

    setState(() {
      _obteniendoUbicacion = true;
    });

    try {
      final permisoConcedido = await _solicitarPermiso();

      if (!permisoConcedido) return;

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 25),
        ),
      );

      final nuevaPosicion = LatLng(posicion.latitude, posicion.longitude);

      if (!mounted) return;

      setState(() {
        _centro = nuevaPosicion;
      });

      _mapController.move(nuevaPosicion, 16);
    } catch (e) {
      _mensaje('No se pudo obtener tu ubicación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _obteniendoUbicacion = false;
        });
      }
    }
  }

  // =========================================================
  // CONFIRMAR UBICACIÓN Y OBTENER COLONIA
  // =========================================================

  Future<void> _confirmarUbicacion() async {
    if (_confirmando) return;

    setState(() {
      _confirmando = true;
    });

    try {
      // Tomar el punto que está debajo del marcador central.
      final punto = _mapController.camera.center;

      final lugares = await geo.placemarkFromCoordinates(
        punto.latitude,
        punto.longitude,
      );

      if (!mounted) return;

      if (lugares.isEmpty) {
        _mensaje(
          'No se pudo identificar esta zona. '
          'Intenta seleccionar otro punto.',
        );
        return;
      }

      final lugar = lugares.first;

      String zona = lugar.subLocality?.trim() ?? '';

      if (zona.isEmpty) {
        zona = lugar.locality?.trim() ?? '';
      }

      if (zona.isEmpty) {
        zona = lugar.subAdministrativeArea?.trim() ?? '';
      }

      if (zona.isEmpty) {
        zona = lugar.name?.trim() ?? '';
      }

      if (zona.isEmpty) {
        _mensaje('No se pudo identificar la colonia de este punto.');
        return;
      }

      // Solo devolvemos el nombre de la zona.
      // No devolvemos ni guardamos coordenadas.
      Navigator.pop(context, zona);
    } catch (e) {
      _mensaje(
        'No se pudo identificar la zona seleccionada. '
        'Comprueba tu conexión a internet.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _confirmando = false;
        });
      }
    }
  }

  // =========================================================
  // MENSAJES
  // =========================================================

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // =========================================================
  // INTERFAZ
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
          'Seleccionar ubicación',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        iconTheme: const IconThemeData(color: DaleColores.carbon),
      ),
      body: Column(
        children: [
          // Instrucciones.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            color: DaleColores.crema,
            child: const Text(
              'Mueve el mapa hasta colocar el marcador '
              'sobre la colonia o zona donde se encuentra tu objeto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DaleColores.grisMusgo,
                fontSize: 13,
                height: 1.4,
                fontFamily: 'Roboto',
              ),
            ),
          ),

          // Mapa.
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _centro,
                    initialZoom: 14,
                    minZoom: 5,
                    maxZoom: 19,
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture && mounted) {
                        setState(() {
                          _centro = camera.center;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.daleotravuelta',
                    ),
                  ],
                ),

                // Marcador fijo en el centro del mapa.
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: DaleColores.verdeBosque,
                          size: 48,
                        ),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: DaleColores.verdeBosque,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón para volver a mi ubicación.
                Positioned(
                  right: 15,
                  bottom: 18,
                  child: Material(
                    color: Colors.white,
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _obteniendoUbicacion ? null : _irAMiUbicacion,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: _obteniendoUbicacion
                              ? const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DaleColores.verdeBosque,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                  color: DaleColores.verdeBosque,
                                  size: 25,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel inferior.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DaleColores.verdeBosque,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La ubicación será aproximada.',
                        style: TextStyle(
                          color: DaleColores.carbon,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  'Solo utilizaremos el nombre de la colonia '
                  'o zona. No guardaremos las coordenadas GPS '
                  'ni tu dirección exacta.',
                  style: TextStyle(
                    color: DaleColores.grisMusgo,
                    fontSize: 12,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _confirmando ? null : _confirmarUbicacion,
                    icon: _confirmando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _confirmando
                          ? 'Identificando zona...'
                          : 'Confirmar esta zona',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DaleColores.verdeBosque,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
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
}
