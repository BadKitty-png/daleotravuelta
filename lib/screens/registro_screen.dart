import 'package:flutter/material.dart';

import '../services/usuario_service.dart'; //Import para base de datos

import '../models/sesion.dart';
import 'dashboard_router.dart';
import 'login_screen.dart' show municipiosGto;

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  String? _municipio;
  RolUsuario _rol = RolUsuario.usuario;

  bool _terminos = false;
  bool _errorTerminos = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;
  bool _guardando = false; //NUeva funcion version prueba

  static const Color verde = Color(0xFF3D7050);
  static const Color verdeClaro = Color(0xFF4F8A65);
  static const Color lima = Color(0xFFC2DA8D);
  static const Color crema = Color(0xFFF7F8F5);
  static const Color fondoInput = Color(0xFFF2F5F0);
  static const Color texto = Color(0xFF1E2420);
  static const Color gris = Color(0xFF5C6660);

  TextStyle get estilo => const TextStyle(fontFamily: 'Roboto');

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (_guardando) return;

    final ok = _formKey.currentState!.validate();

    setState(() {
      _errorTerminos = !_terminos;
    });

    if (!ok || !_terminos) return;

    setState(() {
      _guardando = true;
    });

    try {
      // Registrar cuenta en SQLite
      await UsuarioService.instance.registrarUsuario(
        nombre: _nombre.text.trim(),
        correo: _correo.text.trim(),
        password: _password.text,
        municipio: _municipio!,
        rol: _rol.name,
      );

      // Iniciar sesión automáticamente
      await UsuarioService.instance.iniciarSesion(
        correo: _correo.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      // Actualizar los datos de la sesión en memoria
      Sesion.nombre = _nombre.text.trim();
      Sesion.correo = _correo.text.trim().toLowerCase();
      Sesion.municipio = _municipio!;
      Sesion.rol = _rol;

      // Ir al panel correspondiente
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardRouter()),
        (r) => false,
      );
    } catch (e) {
      if (!mounted) return;

      final mensaje = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _construirHero(),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _construirFormulario(),
                ),
              ),

              const SizedBox(height: 5),
              _construirInsignia(),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // HERO
  Widget _construirHero() {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: ClipPath(
        clipper: RegistroCurvaClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [verde, verdeClaro],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: -65, right: -45, child: _circulo(180)),
              Positioned(bottom: -65, left: -35, child: _circulo(160)),
              Positioned(
                right: 25,
                bottom: 40,
                child: Icon(
                  Icons.eco_outlined,
                  size: 65,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logo(),
                    const SizedBox(height: 12),
                    Text(
                      'Únete a Dale la Vuelta',
                      style: estilo.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Cada objeto merece otra oportunidad',
                      style: estilo.copyWith(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circulo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 2,
        ),
      ),
    );
  }

  Widget _logo() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF83A98B),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 49,
            height: 49,
            decoration: const BoxDecoration(
              color: verde,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 29,
            height: 29,
            decoration: const BoxDecoration(
              color: lima,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: verde, size: 18),
          ),
        ],
      ),
    );
  }

  // FORMULARIO
  Widget _construirFormulario() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E8E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crea tu cuenta',
              style: estilo.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: texto,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Forma parte de una comunidad que transforma el consumo.',
              style: estilo.copyWith(fontSize: 12, color: gris),
            ),

            const SizedBox(height: 24),

            _etiqueta('Nombre completo'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              style: estilo.copyWith(fontSize: 13, color: texto),
              decoration: _decoracion(
                Icons.person_outline,
                'Escribe tu nombre completo',
              ),
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Escribe tu nombre'
                  : null,
            ),

            const SizedBox(height: 17),

            _etiqueta('Correo electrónico'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              style: estilo.copyWith(fontSize: 13, color: texto),
              decoration: _decoracion(Icons.email_outlined, 'tu@correo.com'),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Escribe tu correo';
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                return ok ? null : 'Correo no válido';
              },
            ),

            const SizedBox(height: 17),

            _etiqueta('Contraseña'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _password,
              obscureText: _ocultarPassword,
              style: estilo.copyWith(fontSize: 13, color: texto),
              decoration: _decoracion(
                Icons.lock_outline,
                'Mínimo 8 caracteres',
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarPassword = !_ocultarPassword;
                    });
                  },
                  icon: Icon(
                    _ocultarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: gris,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Escribe una contraseña';
                }
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),

            const SizedBox(height: 17),

            _etiqueta('Confirmar contraseña'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmar,
              obscureText: _ocultarConfirmar,
              style: estilo.copyWith(fontSize: 13, color: texto),
              decoration: _decoracion(
                Icons.lock_reset_rounded,
                'Repite tu contraseña',
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultarConfirmar = !_ocultarConfirmar;
                    });
                  },
                  icon: Icon(
                    _ocultarConfirmar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: gris,
                  ),
                ),
              ),
              validator: (v) =>
                  v != _password.text ? 'Las contraseñas no coinciden' : null,
            ),

            const SizedBox(height: 17),

            _etiqueta('Tu municipio'),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _municipio,
              isExpanded: true,
              style: estilo.copyWith(fontSize: 13, color: texto),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: verde),
              decoration: _decoracion(
                Icons.location_on_outlined,
                'Selecciona tu municipio',
              ),
              items: municipiosGto.map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (v) => setState(() => _municipio = v),
              validator: (v) => v == null ? 'Selecciona tu municipio' : null,
            ),

            const SizedBox(height: 26),

            // ROL
            Text(
              '¿Cómo usarás la app?',
              style: estilo.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: texto,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona el perfil que mejor se adapte a ti.',
              style: estilo.copyWith(fontSize: 12, color: gris),
            ),
            const SizedBox(height: 13),

            ...[RolUsuario.usuario, RolUsuario.organizacion].map(_construirRol),

            const SizedBox(height: 15),

            // TÉRMINOS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: fondoInput,
                borderRadius: BorderRadius.circular(13),
              ),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: verde,
                value: _terminos,
                onChanged: (v) {
                  setState(() {
                    _terminos = v ?? false;
                    _errorTerminos = false;
                  });
                },
                title: Text(
                  'Acepto los términos y condiciones',
                  style: estilo.copyWith(
                    fontSize: 12,
                    color: texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: _errorTerminos
                    ? Text(
                        'Debes aceptar para continuar',
                        style: estilo.copyWith(
                          fontSize: 11,
                          color: Colors.redAccent,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 22),

            // BOTÓN
            _construirBoton(),

            const SizedBox(height: 18),

            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: estilo.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: verde,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ETIQUETAS
  Widget _etiqueta(String textoEtiqueta) {
    return Text(
      textoEtiqueta,
      style: estilo.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: texto,
      ),
    );
  }

  // INPUTS
  InputDecoration _decoracion(IconData icono, String hint, {Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: fondoInput,
      hintText: hint,
      hintStyle: estilo.copyWith(color: const Color(0xFF9AA49C), fontSize: 12),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(9),
        child: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: lima, shape: BoxShape.circle),
          child: Icon(icono, color: verde, size: 18),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 57, minHeight: 52),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verde, width: 1.3),
      ),
    );
  }

  // SELECCIÓN DE ROL
  Widget _construirRol(RolUsuario r) {
    final seleccionado = _rol == r;

    IconData icono;
    switch (r) {
      case RolUsuario.usuario:
        icono = Icons.person_outline_rounded;
        break;
      case RolUsuario.organizacion:
        icono = Icons.business_outlined;
        break;
      case RolUsuario.administrador:
        icono = Icons.admin_panel_settings_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _rol = r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? lima.withValues(alpha: 0.25) : fondoInput,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: seleccionado ? verde : const Color(0xFFE4E8E2),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: seleccionado ? lima : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: verde, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.nombre,
                    style: estilo.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: texto,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.descripcion,
                    style: estilo.copyWith(fontSize: 11, color: gris),
                  ),
                ],
              ),
            ),
            Icon(
              seleccionado ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: seleccionado ? verde : gris,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // BOTÓN
  Widget _construirBoton() {
    return Container(
      height: 53,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [verde, verdeClaro]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: verde.withValues(alpha: 0.28),
            blurRadius: 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _guardando ? null : _crear,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_guardando) ...[
                const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Guardando cuenta...',
                  style: estilo.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ] else ...[
                Text(
                  'Crear cuenta',
                  style: estilo.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // INSIGNIA
  Widget _construirInsignia() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: lima.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, color: verde, size: 18),
          const SizedBox(width: 7),
          Text(
            'Pequeñas acciones, grandes cambios',
            style: estilo.copyWith(
              color: verde,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class RegistroCurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
