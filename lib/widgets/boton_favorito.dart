import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/favorito_service.dart';
import 'estilo_app.dart';

class BotonFavorito extends StatefulWidget {
  final int? publicacionId;
  final double size;
  final Color backgroundColor;

  const BotonFavorito({
    super.key,
    required this.publicacionId,
    this.size = 40,
    this.backgroundColor = Colors.white,
  });

  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  bool _esFavorito = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _consultarEstado();
  }

  @override
  void didUpdateWidget(covariant BotonFavorito oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.publicacionId != widget.publicacionId) {
      _consultarEstado();
    }
  }

  Future<void> _consultarEstado() async {
    final publicacionId = widget.publicacionId;

    if (publicacionId == null || Sesion.usuarioId == null) {
      if (mounted) {
        setState(() {
          _esFavorito = false;
          _cargando = false;
        });
      }
      return;
    }

    try {
      final favorito = await FavoritoService.instance.esFavorito(publicacionId);

      if (!mounted) return;

      setState(() {
        _esFavorito = favorito;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _cargando = false);
    }
  }

  Future<void> _alternar() async {
    final publicacionId = widget.publicacionId;

    if (Sesion.usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar favoritos.'),
        ),
      );
      return;
    }

    if (publicacionId == null || _cargando) return;

    setState(() => _cargando = true);

    try {
      final favorito = await FavoritoService.instance.alternarFavorito(
        publicacionId,
      );

      if (!mounted) return;

      setState(() {
        _esFavorito = favorito;
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            favorito
                ? 'Producto agregado a favoritos.'
                : 'Producto eliminado de favoritos.',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      shape: const CircleBorder(),
      elevation: 2,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _cargando
            ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DaleColores.verdeBosque,
                ),
              )
            : IconButton(
                padding: EdgeInsets.zero,
                tooltip: _esFavorito
                    ? 'Eliminar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: _alternar,
                icon: Icon(
                  _esFavorito ? Icons.eco_rounded : Icons.eco_outlined,
                  color: _esFavorito
                      ? DaleColores.ambar
                      : DaleColores.verdeBosque,
                  size: widget.size * 0.55,
                ),
              ),
      ),
    );
  }
}
