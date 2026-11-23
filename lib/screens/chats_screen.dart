import 'package:flutter/material.dart';

import 'chat_detalle_screen.dart';

import '../widgets/estilo_app.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversaciones = [
      {
        'nombre': 'María López',
        'mensaje': '¿Todavía tienes la bicicleta?',
        'hora': '10:42',
        'inicial': 'M',
        'color': DaleColores.verdeLima,
        'noLeidos': '2',
      },
      {
        'nombre': 'Carlos Ramírez',
        'mensaje': 'Me interesa el intercambio.',
        'hora': 'Ayer',
        'inicial': 'C',
        'color': DaleColores.ambar,
        'noLeidos': '',
      },
    ];

    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: DecoracionOrganica()),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conecta y comparte',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Comunícate con otras personas y dale una nueva vuelta a los objetos.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const LogoDaleVuelta(size: 58),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Tus conversaciones',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Mantente en contacto con compradores y vendedores.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 16),

          for (final chat in conversaciones)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: DaleColores.borde),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: chat['color'] as Color,
                  child: Text(
                    chat['inicial'] as String,
                    style: const TextStyle(
                      color: DaleColores.carbon,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatDetalleScreen(
                        nombre: chat['nombre'] as String,
                        inicial: chat['inicial'] as String,
                        color: chat['color'] as Color,
                      ),
                    ),
                  );
                },
                title: Text(
                  chat['nombre'] as String,
                  style: const TextStyle(
                    color: DaleColores.carbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    chat['mensaje'] as String,
                    style: const TextStyle(
                      color: DaleColores.grisMusgo,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat['hora'] as String,
                      style: const TextStyle(
                        color: DaleColores.grisMusgo,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if ((chat['noLeidos'] as String).isNotEmpty)
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: DaleColores.verdeBosque,
                        child: Text(
                          chat['noLeidos'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: DaleColores.verdeLima.withOpacity(0.25),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_outlined, color: DaleColores.verdeBosque),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cada conversación puede ayudar a que un objeto encuentre un nuevo hogar.',
                    style: TextStyle(
                      color: DaleColores.carbon,
                      fontSize: 12,
                      height: 1.4,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
