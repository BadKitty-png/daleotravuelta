import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/favorito_service.dart';
import '../widgets/estilo_app.dart';
import '../widgets/producto_card.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  late Future<List<Map<String, dynamic>>> _favoritosFuture;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  void _cargarFavoritos() {
    _favoritosFuture = FavoritoService.instance.obtenerFavoritos();
  }

  Future<void> _actualizarFavoritos() async {
    setState(_cargarFavoritos);
    await _favoritosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        foregroundColor: DaleColores.carbon,
        elevation: 0,
        title: const Text(
          'Mis favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Sesion.usuarioId == null
          ? _mensajeSinSesion()
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _favoritosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: DaleColores.verdeBosque,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _mensajeError(snapshot.error);
                }

                final registros = snapshot.data ?? [];

                if (registros.isEmpty) {
                  return RefreshIndicator(
                    color: DaleColores.verdeBosque,
                    onRefresh: _actualizarFavoritos,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 130),
                        _EstadoFavoritosVacio(),
                      ],
                    ),
                  );
                }

                final productos = registros
                    .map(Producto.desdeMapa)
                    .toList(growable: false);

                return RefreshIndicator(
                  color: DaleColores.verdeBosque,
                  onRefresh: _actualizarFavoritos,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(producto: productos[index]);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _mensajeSinSesion() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: DaleColores.grisMusgo,
            ),
            SizedBox(height: 16),
            Text(
              'Inicia sesión para consultar tus productos favoritos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DaleColores.carbon,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensajeError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: DaleColores.ambar,
            ),
            const SizedBox(height: 14),
            const Text(
              'No pudimos cargar tus favoritos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DaleColores.carbon,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(_cargarFavoritos),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar de nuevo'),
              style: FilledButton.styleFrom(
                backgroundColor: DaleColores.verdeBosque,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoFavoritosVacio extends StatelessWidget {
  const _EstadoFavoritosVacio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 76,
            color: DaleColores.grisMusgo,
          ),
          SizedBox(height: 18),
          Text(
            'Todavía no tienes favoritos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona el corazón de una publicación para guardarla aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
