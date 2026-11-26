import 'package:flutter/material.dart';

import '../models/sesion.dart';
import 'main_shell.dart';
import 'dashboard_organizacion_screen.dart';
import 'dashboard_admin_screen.dart';

/// Elige la pantalla inicial según el tipo de usuario.
class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    switch (Sesion.rol) {
      case RolUsuario.usuario:
        // El usuario normal entra primero a Inicio.
        return const MainShell();

      case RolUsuario.organizacion:
        return const DashboardOrganizacionScreen();

      case RolUsuario.administrador:
        return const DashboardAdminScreen();
    }
  }
}
