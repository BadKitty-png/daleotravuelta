/// Tipos de usuario de la app.
enum RolUsuario { usuario, organizacion, administrador }

extension RolUsuarioX on RolUsuario {
  String get nombre {
    switch (this) {
      case RolUsuario.usuario:
        return 'Usuario';
      case RolUsuario.organizacion:
        return 'Organización';
      case RolUsuario.administrador:
        return 'Administrador';
    }
  }

  String get descripcion {
    switch (this) {
      case RolUsuario.usuario:
        return 'Vende, dona o intercambia tus cosas';
      case RolUsuario.organizacion:
        return 'Recibe donaciones para tu causa';
      case RolUsuario.administrador:
        return 'Revisa publicaciones y reportes';
    }
  }
}

/// Sesión de ejemplo (solo maquetado, sin backend).
class Sesion {
  static String nombre = 'Nombre de usuario';
  static String correo = '';
  static String municipio = 'Dolores Hidalgo';
  static RolUsuario rol = RolUsuario.usuario;
}
