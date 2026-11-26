import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/chat_service.dart';
import '../widgets/estilo_app.dart';

class ChatDetalleScreen extends StatefulWidget {
  final int conversacionId;
  final String nombre;
  final String inicial;
  final Color color;

  const ChatDetalleScreen({
    super.key,
    required this.conversacionId,
    required this.nombre,
    required this.inicial,
    required this.color,
  });

  @override
  State<ChatDetalleScreen> createState() => _ChatDetalleScreenState();
}

class _ChatDetalleScreenState extends State<ChatDetalleScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _mensajes = [];
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    try {
      await ChatService.instance.marcarComoLeidos(widget.conversacionId);

      final mensajes = await ChatService.instance.obtenerMensajes(
        widget.conversacionId,
      );

      if (!mounted) return;

      setState(() {
        _mensajes = mensajes;
        _cargando = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _enviarMensaje() async {
    if (_enviando) return;

    final texto = _mensajeController.text.trim();

    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    try {
      await ChatService.instance.enviarMensaje(
        conversacionId: widget.conversacionId,
        texto: texto,
      );

      _mensajeController.clear();
      await _cargarMensajes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
              child: Text(
                widget.nombre,
                style: const TextStyle(
                  color: DaleColores.carbon,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _mensajes.isEmpty
                ? const Center(
                    child: Text(
                      'Inicia la conversación',
                      style: TextStyle(color: DaleColores.grisMusgo),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarMensajes,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _mensajes.length,
                      itemBuilder: (context, index) {
                        final mensaje = _mensajes[index];
                        final autorId = (mensaje['autor_id'] as num).toInt();
                        final esMio = autorId == Sesion.usuarioId;

                        return Align(
                          alignment: esMio
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: esMio
                                  ? DaleColores.verdeBosque
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: esMio
                                  ? null
                                  : Border.all(color: DaleColores.borde),
                            ),
                            child: Text(
                              mensaje['texto'] as String,
                              style: TextStyle(
                                color: esMio
                                    ? Colors.white
                                    : DaleColores.carbon,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: DaleColores.crema,
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
                    onPressed: _enviando ? null : _enviarMensaje,
                    icon: _enviando
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
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
