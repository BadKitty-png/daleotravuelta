import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'buscar_screen.dart';
import 'chats_screen.dart';
import 'perfil_screen.dart';
import 'publicar_tipo_screen.dart';

/// Barra de navegación inferior: Inicio, Buscar, Publicar (+), Chats, Perfil
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Índice de la página mostrada (0..3). "Publicar" no es una pestaña, abre un flujo.
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
      body: IndexedStack(index: _pagina, children: _paginas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (i) {
          if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PublicarTipoScreen()),
            );
          } else {
            setState(() => _pagina = i > 2 ? i - 1 : i);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
