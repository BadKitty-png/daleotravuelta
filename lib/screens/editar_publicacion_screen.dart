import 'package:flutter/material.dart';

import '../models/sesion.dart';
import '../services/publicacion_service.dart';
import '../widgets/estilo_app.dart';
import 'seleccionar_ubicacion_screen.dart';

class EditarPublicacionScreen extends StatefulWidget {
  final Map<String, dynamic> publicacion;

  const EditarPublicacionScreen({super.key, required this.publicacion});

  @override
  State<EditarPublicacionScreen> createState() =>
      _EditarPublicacionScreenState();
}

class _EditarPublicacionScreenState extends State<EditarPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titulo;
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _anio;
  late final TextEditingController _talla;
  late final TextEditingController _descripcion;
  late final TextEditingController _numeroSerie;
  late final TextEditingController _caracteristicas;
  late final TextEditingController _precio;
  late final TextEditingController _colonia;
  late final TextEditingController _municipio;

  late String _categoria;
  late String _modalidad;
  late String _estadoProducto;
  late bool _aceptaOfertas;

  bool _guardando = false;
  bool _zonaActualizada = false;

  static const List<String> _categorias = [
    'Bicicletas',
    'Electrónicas',
    'Muebles',
    'Ropa',
    'Otros productos',
  ];

  static const List<String> _modalidades = [
    'Vender',
    'Donar',
    'Intercambiar',
    'Subastar',
  ];

  static const List<String> _estados = [
    'Buen estado',
    'Como nueva',
    'Para reparar',
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.publicacion;

    _titulo = TextEditingController(text: _texto(p['titulo']));
    _marca = TextEditingController(text: _texto(p['marca']));
    _modelo = TextEditingController(text: _texto(p['modelo']));
    _anio = TextEditingController(text: _texto(p['anio']));
    _talla = TextEditingController(text: _texto(p['talla']));
    _descripcion = TextEditingController(text: _texto(p['descripcion']));
    _numeroSerie = TextEditingController(text: _texto(p['numero_serie']));
    _caracteristicas = TextEditingController(
      text: _texto(p['caracteristicas']),
    );
    _precio = TextEditingController(text: _texto(p['precio']));
    _colonia = TextEditingController(text: _texto(p['colonia']));
    _municipio = TextEditingController(text: _texto(p['municipio']));

    _categoria = _valorValido(_texto(p['categoria']), _categorias);

    _modalidad = _valorValido(_texto(p['modalidad']), _modalidades);

    _estadoProducto = _valorValido(_texto(p['estado_producto']), _estados);

    _aceptaOfertas = p['acepta_ofertas'] == 1 || p['acepta_ofertas'] == true;
  }

  String _texto(Object? valor) => valor?.toString() ?? '';

  String _valorValido(String valor, List<String> opciones) {
    return opciones.contains(valor) ? valor : opciones.first;
  }

  @override
  void dispose() {
    for (final controller in [
      _titulo,
      _marca,
      _modelo,
      _anio,
      _talla,
      _descripcion,
      _numeroSerie,
      _caracteristicas,
      _precio,
      _colonia,
      _municipio,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  // =========================================================
  // SELECCIONAR NUEVA ZONA EN EL MAPA
  // =========================================================

  Future<void> _seleccionarZona() async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SeleccionarUbicacionScreen()),
    );

    if (!mounted || resultado == null || resultado.trim().isEmpty) {
      return;
    }

    setState(() {
      _colonia.text = resultado.trim();
      _zonaActualizada = true;
    });

    _mensaje('La nueva zona se ha seleccionado correctamente.');
  }

  void _borrarZona() {
    setState(() {
      _colonia.clear();
      _zonaActualizada = true;
    });
  }

  // =========================================================
  // GUARDAR CAMBIOS
  // =========================================================

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _guardando) {
      return;
    }

    final usuarioId = Sesion.usuarioId;
    final publicacionId = (widget.publicacion['id'] as num?)?.toInt();

    if (usuarioId == null || publicacionId == null) {
      _mensaje('No se pudo identificar la publicación o el usuario.');
      return;
    }

    double precio = 0;

    if (_modalidad == 'Vender' || _modalidad == 'Subastar') {
      precio = double.tryParse(_precio.text.trim().replaceAll(',', '.')) ?? 0;

      if (precio <= 0) {
        _mensaje('Ingresa un precio válido mayor que cero.');
        return;
      }
    }

    setState(() => _guardando = true);

    try {
      final filas = await PublicacionService.instance.actualizarPublicacion(
        publicacionId: publicacionId,
        usuarioId: usuarioId,
        categoria: _categoria,
        modalidad: _modalidad,
        titulo: _titulo.text.trim(),
        marca: _marca.text.trim(),
        modelo: _modelo.text.trim(),
        anio: int.tryParse(_anio.text.trim()),
        talla: _talla.text.trim(),
        estadoProducto: _estadoProducto,
        descripcion: _descripcion.text.trim(),
        numeroSerie: _numeroSerie.text.trim(),
        caracteristicas: _caracteristicas.text.trim(),
        aceptaOfertas:
            (_modalidad == 'Vender' || _modalidad == 'Subastar') &&
            _aceptaOfertas,
        precio: precio,
        colonia: _colonia.text.trim(),
        municipio: _municipio.text.trim(),
      );

      if (!mounted) return;

      if (filas == 0) {
        throw Exception('No tienes permiso para editar esta publicación.');
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _mensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating),
    );
  }

  // =========================================================
  // ESTILOS
  // =========================================================

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono, {
    String? ayuda,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(icono, color: DaleColores.verdeBosque, size: 21),
      filled: true,
      fillColor: const Color(0xFFF9FAF7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      labelStyle: const TextStyle(
        color: DaleColores.grisMusgo,
        fontFamily: 'Roboto',
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF9AA39B),
        fontSize: 13,
        fontFamily: 'Roboto',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: DaleColores.verdeBosque,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // =========================================================
  // INTERFAZ PRINCIPAL
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaleColores.crema,
      appBar: AppBar(
        backgroundColor: DaleColores.crema,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: DaleColores.carbon),
        title: const Text(
          'Editar publicación',
          style: TextStyle(
            color: DaleColores.carbon,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            _encabezado(),

            const SizedBox(height: 24),

            _seccion(
              numero: '01',
              titulo: 'Información del objeto',
              descripcion: 'Actualiza los datos principales de tu publicación.',
              icono: Icons.inventory_2_outlined,
              contenido: [
                _selector(
                  'Categoría',
                  _categoria,
                  _categorias,
                  (v) => setState(() => _categoria = v!),
                  Icons.category_outlined,
                ),
                _selector(
                  'Estado del producto',
                  _estadoProducto,
                  _estados,
                  (v) => setState(() => _estadoProducto = v!),
                  Icons.verified_outlined,
                ),
                _campo(
                  'Título',
                  _titulo,
                  icono: Icons.title_rounded,
                  obligatorio: true,
                  ayuda: 'Ej. Bicicleta de montaña rodada 26',
                ),
                _campo('Marca', _marca, icono: Icons.sell_outlined),
                _campo('Modelo', _modelo, icono: Icons.widgets_outlined),
                _filaDos(
                  _campo(
                    'Año',
                    _anio,
                    icono: Icons.calendar_today_outlined,
                    numero: true,
                  ),
                  _campo('Talla', _talla, icono: Icons.straighten_outlined),
                ),
                _campo(
                  'Descripción',
                  _descripcion,
                  icono: Icons.description_outlined,
                  obligatorio: true,
                  lineas: 4,
                  ayuda: 'Describe las condiciones de tu objeto...',
                ),
                _campo(
                  'Número de serie',
                  _numeroSerie,
                  icono: Icons.qr_code_rounded,
                ),
                _campo(
                  'Características adicionales',
                  _caracteristicas,
                  icono: Icons.tune_rounded,
                  lineas: 3,
                ),
              ],
            ),

            const SizedBox(height: 18),

            _seccion(
              numero: '02',
              titulo: 'Precio y modalidad',
              descripcion: 'Define cómo quieres compartir tu objeto.',
              icono: Icons.handshake_outlined,
              contenido: [
                _selector(
                  'Modalidad',
                  _modalidad,
                  _modalidades,
                  (v) => setState(() => _modalidad = v!),
                  Icons.swap_horiz_rounded,
                ),

                if (_modalidad == 'Vender' || _modalidad == 'Subastar') ...[
                  _campo(
                    'Precio',
                    _precio,
                    icono: Icons.attach_money_rounded,
                    numero: true,
                    obligatorio: true,
                    ayuda: '0.00',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8F1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: DaleColores.borde),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      activeColor: DaleColores.verdeBosque,
                      secondary: const Icon(
                        Icons.forum_outlined,
                        color: DaleColores.verdeBosque,
                      ),
                      title: const Text(
                        'Aceptar ofertas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: DaleColores.carbon,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      subtitle: const Text(
                        'Permite recibir propuestas de otras personas.',
                        style: TextStyle(
                          fontSize: 11,
                          color: DaleColores.grisMusgo,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      value: _aceptaOfertas,
                      onChanged: (valor) {
                        setState(() => _aceptaOfertas = valor);
                      },
                    ),
                  ),
                ] else
                  _avisoModalidad(),
              ],
            ),

            const SizedBox(height: 18),

            _seccion(
              numero: '03',
              titulo: 'Ubicación',
              descripcion:
                  'Mantén actualizada la zona donde se encuentra tu objeto.',
              icono: Icons.location_on_outlined,
              contenido: [
                _tarjetaUbicacion(),

                TextFormField(
                  controller: _colonia,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    setState(() => _zonaActualizada = true);
                  },
                  decoration:
                      _decoracion(
                        'Colonia o zona cercana',
                        Icons.location_city_outlined,
                        ayuda: 'Ej. Centro, San Juan, Las Américas',
                      ).copyWith(
                        suffixIcon: _colonia.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Borrar zona',
                                onPressed: _borrarZona,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: DaleColores.grisMusgo,
                                ),
                              )
                            : null,
                      ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _seleccionarZona,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Actualizar zona desde el mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DaleColores.verdeBosque,
                    side: const BorderSide(color: DaleColores.verdeBosque),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                _campo(
                  'Municipio',
                  _municipio,
                  icono: Icons.location_city_rounded,
                  obligatorio: true,
                  ayuda: 'Ej. Dolores Hidalgo',
                ),

                const Text(
                  'Por privacidad, solamente se guarda el nombre de la colonia o zona y el municipio. No se almacenan coordenadas GPS ni direcciones exactas.',
                  style: TextStyle(
                    color: DaleColores.grisMusgo,
                    fontSize: 11,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // BOTÓN GUARDAR.
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _guardando ? 'Guardando cambios...' : 'Guardar cambios',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DaleColores.verdeBosque,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Cada objeto merece una segunda oportunidad 🌱',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DaleColores.grisMusgo,
                  fontSize: 11,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ENCABEZADO
  // =========================================================

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DaleColores.verdeBosque, DaleColores.verdeClaro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: DaleColores.verdeBosque.withValues(alpha: 0.17),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
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
                      'Dale una vuelta más',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Tu publicación puede seguir haciendo feliz a alguien. Mantén su información al día.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const LogoDaleVuelta(size: 62),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECCIONES
  // =========================================================

  Widget _seccion({
    required String numero,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required List<Widget> contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DaleColores.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icono, color: DaleColores.verdeBosque, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: DaleColores.carbon,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: DaleColores.grisMusgo,
                        fontSize: 11,
                        height: 1.3,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                numero,
                style: const TextStyle(
                  color: DaleColores.verdeClaro,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...contenido.map(
            (widget) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: widget,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CAMPOS
  // =========================================================

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    required IconData icono,
    bool obligatorio = false,
    bool numero = false,
    int lineas = 1,
    String? ayuda,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lineas,
      textCapitalization: lineas > 1
          ? TextCapitalization.sentences
          : TextCapitalization.words,
      keyboardType: numero
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: obligatorio
          ? (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Este campo es obligatorio.';
              }

              if (etiqueta == 'Precio') {
                final cantidad = double.tryParse(
                  valor.trim().replaceAll(',', '.'),
                );

                if (cantidad == null || cantidad <= 0) {
                  return 'Ingresa un precio válido.';
                }
              }

              return null;
            }
          : null,
      decoration: _decoracion(etiqueta, icono, ayuda: ayuda),
    );
  }

  Widget _filaDos(Widget primero, Widget segundo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: primero),
        const SizedBox(width: 10),
        Expanded(child: segundo),
      ],
    );
  }

  // =========================================================
  // SELECTORES
  // =========================================================

  Widget _selector(
    String etiqueta,
    String valor,
    List<String> opciones,
    ValueChanged<String?> onChanged,
    IconData icono,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(
            opcion,
            style: const TextStyle(
              color: DaleColores.carbon,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _decoracion(etiqueta, icono),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(14),
    );
  }

  // =========================================================
  // TARJETA DE UBICACIÓN
  // =========================================================

  Widget _tarjetaUbicacion() {
    final tieneZona = _colonia.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE8D5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: DaleColores.verdeBosque,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieneZona ? _colonia.text : 'Sin zona indicada',
                  style: const TextStyle(
                    color: DaleColores.carbon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tieneZona
                      ? _zonaActualizada
                            ? 'La zona tiene cambios pendientes de guardar.'
                            : 'Esta es la zona registrada actualmente.'
                      : 'Puedes agregar una colonia o zona para orientar a otras personas.',
                  style: const TextStyle(
                    color: DaleColores.grisMusgo,
                    fontSize: 11,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          if (tieneZona)
            const Icon(
              Icons.check_circle_rounded,
              color: DaleColores.verdeBosque,
              size: 20,
            ),
        ],
      ),
    );
  }

  // =========================================================
  // AVISO DE MODALIDAD
  // =========================================================

  Widget _avisoModalidad() {
    final mensaje = _modalidad == 'Donar'
        ? 'Tu objeto estará disponible para quien lo necesite, sin costo.'
        : 'El valor se acordará directamente entre las personas interesadas.';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6ED),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFDCE8D5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volunteer_activism_rounded,
            color: DaleColores.verdeBosque,
            size: 25,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: DaleColores.grisMusgo,
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
}
