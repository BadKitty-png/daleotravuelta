import 'package:sqflite/sqflite.dart';

import '../database/base_datos.dart';

class PublicacionService {
  static final PublicacionService instance = PublicacionService._init();

  PublicacionService._init();

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
  }) async {
    final Database db = await BaseDatos.instance.database;

    final datos = {
      'usuario_id': usuarioId,
      'categoria': categoria,
      'modalidad': modalidad,
      'titulo': titulo,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'talla': talla,
      'estado_producto': estadoProducto,
      'descripcion': descripcion,
      'numero_serie': numeroSerie,
      'caracteristicas': caracteristicas,
      'acepta_ofertas': aceptaOfertas ? 1 : 0,
      'precio': precio,
      'colonia': colonia,
      'municipio': municipio,
      'estado_publicacion': 'activa',
      'fecha_creacion': DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'publicaciones',
      datos,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
