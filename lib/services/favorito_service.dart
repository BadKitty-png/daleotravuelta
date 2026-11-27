import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';
import '../models/sesion.dart';

class FavoritoService {
  FavoritoService._();

  static final FavoritoService instance = FavoritoService._();

  int get _usuarioId {
    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      throw Exception('Debes iniciar sesión para utilizar favoritos.');
    }

    return usuarioId;
  }

  /// Comprueba si una publicación está en los favoritos
  /// del usuario que inició sesión.
  Future<bool> esFavorito(int publicacionId) async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.query(
      'favoritos',
      columns: ['publicacion_id'],
      where: 'usuario_id = ? AND publicacion_id = ?',
      whereArgs: [_usuarioId, publicacionId],
      limit: 1,
    );

    return resultado.isNotEmpty;
  }

  /// Agrega una publicación a favoritos.
  Future<void> agregarFavorito(int publicacionId) async {
    final db = await BaseDatos.instance.database;

    final publicaciones = await db.query(
      'publicaciones',
      columns: ['id', 'estado_publicacion'],
      where: 'id = ?',
      whereArgs: [publicacionId],
      limit: 1,
    );

    if (publicaciones.isEmpty) {
      throw Exception('La publicación ya no existe.');
    }

    final estado = publicaciones.first['estado_publicacion']?.toString();

    if (estado != 'activa') {
      throw Exception('La publicación ya no está disponible.');
    }

    await db.insert('favoritos', {
      'usuario_id': _usuarioId,
      'publicacion_id': publicacionId,
      'fecha_creacion': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Elimina una publicación de favoritos.
  Future<void> eliminarFavorito(int publicacionId) async {
    final db = await BaseDatos.instance.database;

    await db.delete(
      'favoritos',
      where: 'usuario_id = ? AND publicacion_id = ?',
      whereArgs: [_usuarioId, publicacionId],
    );
  }

  /// Agrega o elimina un favorito.
  ///
  /// Devuelve true cuando quedó agregado.
  /// Devuelve false cuando quedó eliminado.
  Future<bool> alternarFavorito(int publicacionId) async {
    final db = await BaseDatos.instance.database;
    final usuarioId = _usuarioId;

    return db.transaction((txn) async {
      final existentes = await txn.query(
        'favoritos',
        columns: ['publicacion_id'],
        where: 'usuario_id = ? AND publicacion_id = ?',
        whereArgs: [usuarioId, publicacionId],
        limit: 1,
      );

      if (existentes.isNotEmpty) {
        await txn.delete(
          'favoritos',
          where: 'usuario_id = ? AND publicacion_id = ?',
          whereArgs: [usuarioId, publicacionId],
        );

        return false;
      }

      final publicaciones = await txn.query(
        'publicaciones',
        columns: ['id', 'estado_publicacion'],
        where: 'id = ?',
        whereArgs: [publicacionId],
        limit: 1,
      );

      if (publicaciones.isEmpty) {
        throw Exception('La publicación ya no existe.');
      }

      final estado = publicaciones.first['estado_publicacion']?.toString();

      if (estado != 'activa') {
        throw Exception('La publicación ya no está disponible.');
      }

      await txn.insert('favoritos', {
        'usuario_id': usuarioId,
        'publicacion_id': publicacionId,
        'fecha_creacion': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      return true;
    });
  }

  /// Obtiene las publicaciones favoritas del usuario
  /// junto con su fotografía de portada.
  Future<List<Map<String, dynamic>>> obtenerFavoritos() async {
    final db = await BaseDatos.instance.database;

    return db.rawQuery(
      '''
      SELECT
        p.*,
        f.fecha_creacion AS fecha_favorito,

        (
          SELECT pi.ruta
          FROM publicacion_imagenes pi
          WHERE pi.publicacion_id = p.id
          ORDER BY pi.posicion ASC, pi.id ASC
          LIMIT 1
        ) AS imagen_portada

      FROM favoritos f

      INNER JOIN publicaciones p
        ON p.id = f.publicacion_id

      WHERE f.usuario_id = ?
        AND p.estado_publicacion = ?

      ORDER BY f.fecha_creacion DESC
      ''',
      [_usuarioId, 'activa'],
    );
  }

  /// Devuelve la cantidad de favoritos del usuario actual.
  Future<int> contarFavoritos() async {
    final db = await BaseDatos.instance.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM favoritos f

      INNER JOIN publicaciones p
        ON p.id = f.publicacion_id

      WHERE f.usuario_id = ?
        AND p.estado_publicacion = ?
      ''',
      [_usuarioId, 'activa'],
    );

    if (resultado.isEmpty) {
      return 0;
    }

    return (resultado.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Elimina todos los favoritos del usuario actual.
  Future<void> eliminarTodos() async {
    final db = await BaseDatos.instance.database;

    await db.delete(
      'favoritos',
      where: 'usuario_id = ?',
      whereArgs: [_usuarioId],
    );
  }
}
