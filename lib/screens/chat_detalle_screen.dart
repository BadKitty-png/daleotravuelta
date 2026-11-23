import 'package:flutter/material.dart';

import '../widgets/estilo_app.dart';

class ChatDetalleScreen extends StatefulWidget {
  final String nombre;
  final String inicial;
  final Color color;

  const ChatDetalleScreen({
    super.key,
    required this.nombre,
    required this.inicial,
    required this.color,
  });

  @override
  State<ChatDetalleScreen> createState() => _ChatDetalleScreenState();
}

class _ChatDetalleScreenState extends State<ChatDetalleScreen> {
  final TextEditingController _mensajeController = TextEditingController();

  final List<Map<String, dynamic>> _mensajes = [
    {'texto': '¡Hola! Me interesa tu publicación.', 'mio': false},
    {'texto': '¡Hola! Claro, ¿qué te gustaría saber?', 'mio': true},
  ];

  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();

    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add({'texto': texto, 'mio': true});
    });

    _mensajeController.clear();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: DaleColores.verdeBosque,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.color,
              child: Text(
                widget.inicial,
                style: const TextStyle(
                  color: DaleColores.carbon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: DaleColores.carbon,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Conversación',
                    style: TextStyle(
                      color: DaleColores.grisMusgo,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                final esMio = mensaje['mio'] as bool;

                return Align(
                  alignment: esMio
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: esMio ? DaleColores.verdeBosque : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: esMio
                          ? null
                          : Border.all(color: DaleColores.borde),
                    ),
                    child: Text(
                      mensaje['texto'] as String,
                      style: TextStyle(
                        color: esMio ? Colors.white : DaleColores.carbon,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: DaleColores.crema,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: DaleColores.verdeBosque,
                  child: IconButton(
                    onPressed: _enviarMensaje,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 19,
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
