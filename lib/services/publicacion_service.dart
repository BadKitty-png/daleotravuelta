import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';
import 'imagen_service.dart';

class PublicacionService {
  static final PublicacionService instance = PublicacionService._init();

  PublicacionService._init();

  // Actualizar una publicación existente.
  Future<int> actualizarPublicacion({
    required int publicacionId,
    required int usuarioId,
    required String categoria,
    required String modalidad,
    required String titulo,
    String? marca,
    String? modelo,
    int? anio,
    String? talla,
    required String estadoProducto,
    required String descripcion,
    String? numeroSerie,
    String? caracteristicas,
    bool aceptaOfertas = false,
    double precio = 0,
    String? colonia,
    required String municipio,
    double? latitud,
    double? longitud,
    String? referencia,
  }) async {
    final Database db = await BaseDatos.instance.database;

    return db.update(
      'publicaciones',
      <String, Object?>{
        'categoria': categoria,
        'modalidad': modalidad,
        'titulo': titulo.trim(),
        'marca': marca?.trim(),
        'modelo': modelo?.trim(),
        'anio': anio,
        'talla': talla?.trim(),
        'estado_producto': estadoProducto,
        'descripcion': descripcion.trim(),
        'numero_serie': numeroSerie?.trim(),
        'caracteristicas': caracteristicas?.trim(),
        'acepta_ofertas': aceptaOfertas ? 1 : 0,
        'precio': precio,
        'colonia': colonia?.trim(),
        'municipio': municipio.trim(),

        // Ubicación GPS.
        'latitud': latitud,
        'longitud': longitud,
        'referencia': referencia?.trim(),
      },
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [publicacionId, usuarioId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obtener todas las publicaciones activas junto con su portada.
  Future<List<Map<String, dynamic>>> obtenerPublicaciones() async {
    final Database db = await BaseDatos.instance.database;

    return db.rawQuery(
      '''
      SELECT
        p.*,
        (
          SELECT pi.ruta
          FROM publicacion_imagenes pi
          WHERE pi.publicacion_id = p.id
          ORDER BY pi.posicion ASC, pi.id ASC
          LIMIT 1
        ) AS imagen_portada
      FROM publicaciones p
      WHERE p.estado_publicacion = ?
      ORDER BY p.fecha_creacion DESC
      ''',
      ['activa'],
    );
  }

  // Obtener publicaciones activas de un usuario junto con su portada.
  Future<List<Map<String, dynamic>>> obtenerMisPublicaciones({
    required int usuarioId,
  }) async {
    final Database db = await BaseDatos.instance.database;

    return db.rawQuery(
      '''
      SELECT
        p.*,
        (
          SELECT pi.ruta
          FROM publicacion_imagenes pi
          WHERE pi.publicacion_id = p.id
          ORDER BY pi.posicion ASC, pi.id ASC
          LIMIT 1
        ) AS imagen_portada
      FROM publicaciones p
      WHERE p.usuario_id = ?
        AND p.estado_publicacion = ?
      ORDER BY p.fecha_creacion DESC
      ''',
      [usuarioId, 'activa'],
    );
  }

  // Obtener todas las fotografías de una publicación
  // en su orden original.
  Future<List<String>> obtenerImagenesPublicacion(int publicacionId) async {
    final Database db = await BaseDatos.instance.database;

    final registros = await db.query(
      'publicacion_imagenes',
      columns: ['ruta'],
      where: 'publicacion_id = ?',
      whereArgs: [publicacionId],
      orderBy: 'posicion ASC, id ASC',
    );

    return registros
        .map((registro) => registro['ruta']?.toString() ?? '')
        .where((ruta) => ruta.isNotEmpty)
        .toList();
  }

  // Guardar una publicación nueva con sus fotografías
  // y su ubicación GPS.
  Future<int> guardarPublicacion({
    required int usuarioId,
    required String categoria,
    required String modalidad,
    required String titulo,
    String? marca,
    String? modelo,
    int? anio,
    String? talla,
    required String estadoProducto,
    required String descripcion,
    String? numeroSerie,
    String? caracteristicas,
    bool aceptaOfertas = false,
    double precio = 0,
    String? colonia,
    required String municipio,
    required List<String> rutasImagenesTemporales,

    // Datos de ubicación GPS.
    double? latitud,
    double? longitud,
    String? referencia,
  }) async {
    // Validar fotografías.
    if (rutasImagenesTemporales.isEmpty) {
      throw Exception('Agrega por lo menos una foto del producto.');
    }

    if (rutasImagenesTemporales.length > 5) {
      throw Exception('Solo puedes guardar un máximo de cinco fotos.');
    }

    // Guardar fotografías en almacenamiento permanente.
    final rutasPermanentes = await ImagenService.instance
        .guardarImagenesPermanentes(rutasImagenesTemporales);

    if (rutasPermanentes.isEmpty) {
      throw Exception('No se pudo guardar ninguna fotografía.');
    }

    final Database db = await BaseDatos.instance.database;

    // Preparar los datos de la publicación.
    final datos = <String, Object?>{
      'usuario_id': usuarioId,
      'categoria': categoria,
      'modalidad': modalidad,
      'titulo': titulo.trim(),
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'talla': talla,
      'estado_producto': estadoProducto,
      'descripcion': descripcion.trim(),
      'numero_serie': numeroSerie,
      'caracteristicas': caracteristicas,
      'acepta_ofertas': aceptaOfertas ? 1 : 0,
      'precio': precio,
      'colonia': colonia,
      'municipio': municipio,

      // Guardar ubicación GPS en SQLite.
      'latitud': latitud,
      'longitud': longitud,
      'referencia': referencia?.trim(),

      'estado_publicacion': 'activa',
      'fecha_creacion': DateTime.now().toIso8601String(),
    };

    try {
      // Guardar publicación y fotografías en una transacción.
      return await db.transaction((txn) async {
        final publicacionId = await txn.insert(
          'publicaciones',
          datos,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        // Relacionar las fotografías con la publicación.
        for (var posicion = 0; posicion < rutasPermanentes.length; posicion++) {
          await txn.insert('publicacion_imagenes', {
            'publicacion_id': publicacionId,
            'ruta': rutasPermanentes[posicion],
            'posicion': posicion,
          }, conflictAlgorithm: ConflictAlgorithm.abort);
        }

        return publicacionId;
      });
    } catch (_) {
      // Si SQLite falla, eliminar las copias para no dejar
      // archivos huérfanos.
      await ImagenService.instance.eliminarImagenes(rutasPermanentes);

      rethrow;
    }
  }
}
