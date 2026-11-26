import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/chat_service.dart';
import '../widgets/estilo_app.dart';
import 'chat_detalle_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late Future<List<Map<String, dynamic>>> _conversacionesFuture;

  @override
  void initState() {
    super.initState();
    _conversacionesFuture = _obtenerConversaciones();
  }

  Future<List<Map<String, dynamic>>> _obtenerConversaciones() {
    if (Sesion.usuarioId == null) {
      return Future.value([]);
    }

    return ChatService.instance.obtenerConversaciones();
  }

  Future<void> _recargarConversaciones() async {
    final nuevaConsulta = _obtenerConversaciones();

    setState(() {
      _conversacionesFuture = nuevaConsulta;
    });

    await nuevaConsulta;
  }

  String _obtenerInicial(String nombre) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return '?';
    }

    return nombreLimpio.substring(0, 1).toUpperCase();
  }

  String _formatearHora(dynamic fechaValor) {
    if (fechaValor == null) {
      return '';
    }

    final fecha = DateTime.tryParse(fechaValor.toString());

    if (fecha == null) {
      return '';
    }

    final ahora = DateTime.now();
    final fechaLocal = fecha.toLocal();

    final esHoy =
        fechaLocal.year == ahora.year &&
        fechaLocal.month == ahora.month &&
        fechaLocal.day == ahora.day;

    if (esHoy) {
      final hora = fechaLocal.hour.toString().padLeft(2, '0');
      final minuto = fechaLocal.minute.toString().padLeft(2, '0');

      return '$hora:$minuto';
    }

    final ayer = ahora.subtract(const Duration(days: 1));

    final fueAyer =
        fechaLocal.year == ayer.year &&
        fechaLocal.month == ayer.month &&
        fechaLocal.day == ayer.day;

    if (fueAyer) {
      return 'Ayer';
    }

    final dia = fechaLocal.day.toString().padLeft(2, '0');
    final mes = fechaLocal.month.toString().padLeft(2, '0');

    return '$dia/$mes';
  }

  Future<void> _abrirConversacion(Map<String, dynamic> chat) async {
    final nombre = (chat['otro_nombre'] as String?)?.trim() ?? 'Usuario';

    final inicial = _obtenerInicial(nombre);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetalleScreen(
          conversacionId: (chat['id'] as num).toInt(),
          nombre: nombre,
          inicial: inicial,
          color: DaleColores.verdeLima,
        ),
      ),
    );

    if (!mounted) return;

    await _recargarConversaciones();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: _recargarConversaciones,
            tooltip: 'Actualizar conversaciones',
            icon: const Icon(
              Icons.refresh_rounded,
              color: DaleColores.verdeBosque,
            ),
          ),
        ],
      ),
      body: Sesion.usuarioId == null
          ? _construirSinSesion()
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _conversacionesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: DaleColores.verdeBosque,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _construirError(snapshot.error);
                }

                final conversaciones = snapshot.data ?? [];

                return RefreshIndicator(
                  color: DaleColores.verdeBosque,
                  onRefresh: _recargarConversaciones,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _construirEncabezado(),

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

                      if (conversaciones.isEmpty)
                        _construirEstadoVacio()
                      else
                        for (final chat in conversaciones)
                          _construirConversacion(chat),

                      const SizedBox(height: 10),

                      _construirMensajeEcologico(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
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
          const Row(
            children: [
              Expanded(
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
              SizedBox(width: 10),
              LogoDaleVuelta(size: 58),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirConversacion(Map<String, dynamic> chat) {
    final nombre = (chat['otro_nombre'] as String?)?.trim() ?? 'Usuario';

    final mensaje = (chat['ultimo_mensaje'] as String?)?.trim() ?? '';

    final tituloPublicacion =
        (chat['publicacion_titulo'] as String?)?.trim() ?? '';

    final noLeidos = (chat['no_leidos'] as num?)?.toInt() ?? 0;

    final inicial = _obtenerInicial(nombre);

    final hora = _formatearHora(chat['ultima_actividad']);

    final textoSecundario = mensaje.isNotEmpty
        ? mensaje
        : tituloPublicacion.isNotEmpty
        ? 'Publicación: $tituloPublicacion'
        : 'Inicia la conversación';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        onTap: () => _abrirConversacion(chat),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: DaleColores.verdeLima,
          child: Text(
            inicial,
            style: const TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            textoSecundario,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: noLeidos > 0 ? DaleColores.carbon : DaleColores.grisMusgo,
              fontSize: 12,
              fontWeight: noLeidos > 0 ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        trailing: SizedBox(
          width: 46,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hora,
                style: const TextStyle(
                  color: DaleColores.grisMusgo,
                  fontSize: 10,
                ),
              ),
              if (noLeidos > 0) ...[
                const SizedBox(height: 6),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: DaleColores.verdeBosque,
                  child: Text(
                    noLeidos > 99 ? '99+' : '$noLeidos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: DaleColores.borde),
      ),
      child: const Column(
        children: [
          Icon(Icons.forum_outlined, size: 52, color: DaleColores.verdeBosque),
          SizedBox(height: 13),
          Text(
            'Aún no tienes conversaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando contactes al propietario de una publicación, la conversación aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              height: 1.4,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMensajeEcologico() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DaleColores.verdeLima.withValues(alpha: 0.25),
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
    );
  }

  Widget _construirSinSesion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DaleColores.borde),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 50,
                color: DaleColores.verdeBosque,
              ),
              SizedBox(height: 14),
              Text(
                'Inicia sesión para consultar tus mensajes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DaleColores.carbon,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: DaleColores.carbon),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _recargarConversaciones,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DaleColores.verdeBosque,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
