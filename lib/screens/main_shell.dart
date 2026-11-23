import 'package:flutter/material.dart';

import '../widgets/estilo_app.dart';
import 'inicio_screen.dart';
import 'buscar_screen.dart';
import 'chats_screen.dart';
import 'perfil_screen.dart';
import 'publicar_tipo_screen.dart';

/// Barra de navegación inferior:
/// Inicio, Buscar, Publicar, Chats y Perfil.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Índice de la página mostrada (0..3).
  // Publicar abre un flujo independiente.
  int _pagina = 0;

  static const _paginas = [
    InicioScreen(),
    BuscarScreen(),
    ChatsScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navIndex = _pagina >= 2 ? _pagina + 1 : _pagina;

    return Scaffold(
      backgroundColor: DaleColores.crema,
      body: IndexedStack(index: _pagina, children: _paginas),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: DaleColores.verdeLima.withOpacity(0.45),
          height: 68,
          elevation: 8,
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final seleccionado = states.contains(WidgetState.selected);

            return TextStyle(
              color: seleccionado
                  ? DaleColores.verdeBosque
                  : DaleColores.grisMusgo,
              fontSize: 11,
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Roboto',
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            final seleccionado = states.contains(WidgetState.selected);

            return IconThemeData(
              color: seleccionado
                  ? DaleColores.verdeBosque
                  : DaleColores.grisMusgo,
              size: 23,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: navIndex,
          onDestinationSelected: (i) {
            if (i == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PublicarTipoScreen()),
              );
            } else {
              setState(() {
                _pagina = i > 2 ? i - 1 : i;
              });
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_rounded),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'Publicar',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
