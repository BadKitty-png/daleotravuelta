import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImagenService {
  ImagenService._();

  static final ImagenService instance = ImagenService._();

  Future<List<String>> guardarImagenesPermanentes(
    List<String> rutasTemporales,
  ) async {
    if (rutasTemporales.isEmpty) return [];

    final directorioApp = await getApplicationDocumentsDirectory();
    final directorioImagenes = Directory(
      path.join(directorioApp.path, 'publicaciones'),
    );

    if (!await directorioImagenes.exists()) {
      await directorioImagenes.create(recursive: true);
    }

    final rutasGuardadas = <String>[];

    try {
      for (var i = 0; i < rutasTemporales.length; i++) {
        final archivoTemporal = File(rutasTemporales[i]);

        if (!await archivoTemporal.exists()) continue;

        final extension = path.extension(archivoTemporal.path).isEmpty
            ? '.jpg'
            : path.extension(archivoTemporal.path).toLowerCase();

        final nombre =
            'producto_${DateTime.now().microsecondsSinceEpoch}_$i$extension';

        final destino = path.join(directorioImagenes.path, nombre);
        final archivoGuardado = await archivoTemporal.copy(destino);

        rutasGuardadas.add(archivoGuardado.path);
      }

      return rutasGuardadas;
    } catch (_) {
      await eliminarImagenes(rutasGuardadas);
      rethrow;
    }
  }

  Future<void> eliminarImagenes(List<String> rutas) async {
    for (final ruta in rutas) {
      try {
        final archivo = File(ruta);

        if (await archivo.exists()) {
          await archivo.delete();
        }
      } catch (_) {
        // Un archivo inexistente no debe bloquear el resto de la operación.
      }
    }
  }
}
