import 'package:flutter/material.dart';
import '../models/sesion.dart';
import 'dashboard_usuario_screen.dart';
import 'dashboard_organizacion_screen.dart';
import 'dashboard_admin_screen.dart';

/// Elige el dashboard según el tipo de usuario.
class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Sesion.rol) {
      case RolUsuario.usuario:
        return const DashboardUsuarioScreen();
      case RolUsuario.organizacion:
        return const DashboardOrganizacionScreen();
      case RolUsuario.administrador:
        return const DashboardAdminScreen();
    }
  }
}
