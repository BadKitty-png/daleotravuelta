import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/usuario_service.dart';
import '../models/sesion.dart';
import 'dashboard_router.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _password = TextEditingController();

  bool _ocultar = true;

  // Paleta de Dale la Vuelta
  static const Color verdeBosque = Color(0xFF3D7050);
  static const Color verdeClaro = Color(0xFF4F8A65);
  static const Color verdeLima = Color(0xFFC2DA8D);
  static const Color ambar = Color(0xFFD4AF37);
  static const Color crema = Color(0xFFF7F8F5);
  static const Color fondoInput = Color(0xFFF2F5F0);
  static const Color texto = Color(0xFF1E2420);
  static const Color textoSecundario = Color(0xFF5C6660);

  TextStyle get estilo => const TextStyle(fontFamily: 'Roboto');

  @override
  void dispose() {
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  // ------------------------------------------
  // INICIAR SESIÓN
  // ------------------------------------------

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;

    // ACCESO DE ADMINISTRADOR PARA DEMOSTRACIÓN
    if (_correo.text.trim().toLowerCase() == 'admin@dalelavuelta.com' &&
        _password.text == 'Admin12345') {
      Sesion.usuarioId = null;
      Sesion.nombre = 'Administrador';
      Sesion.correo = 'admin@dalelavuelta.com';
      Sesion.municipio = 'Dolores Hidalgo';
      Sesion.rol = RolUsuario.administrador;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardRouter()),
      );

      return;
    }

    _iniciarSesionNormal();
  }

  // ------------------------------------------
  // VALIDAR USUARIO EN SQLITE
  // ------------------------------------------

  Future<void> _iniciarSesionNormal() async {
    try {
      final usuario = await UsuarioService.instance.iniciarSesion(
        correo: _correo.text.trim(),
        password: _password.text,
      );

      Sesion.usuarioId = (usuario['id'] as num).toInt();
      Sesion.nombre = usuario['nombre'] as String;
      Sesion.correo = usuario['correo'] as String;
      Sesion.municipio = usuario['municipio'] as String;

      Sesion.rol = RolUsuario.values.firstWhere(
        (rol) => rol.name == usuario['rol'],
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardRouter()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------
  // CONSTRUCCIÓN PRINCIPAL
  // ------------------------------------------

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
                offset: const Offset(0, -38),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _construirFormulario(),
                ),
              ),

              const SizedBox(height: 0),

              Transform.translate(
                offset: const Offset(0, -20),
                child: _construirInsignia(),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // HERO / CABECERA
  // ------------------------------------------

  Widget _construirHero() {
    return SizedBox(
      height: 290,
      width: double.infinity,
      child: ClipPath(
        clipper: CurvaInferiorClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [verdeBosque, verdeClaro],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -75,
                right: -55,
                child: _circuloDecorativo(210, 0.08),
              ),
              Positioned(
                bottom: -90,
                left: -65,
                child: _circuloDecorativo(220, 0.08),
              ),
              Positioned(
                top: 55,
                left: 25,
                child: Icon(
                  Icons.eco_outlined,
                  size: 55,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 30,
                bottom: 45,
                child: Icon(
                  Icons.autorenew,
                  size: 75,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Positioned(
                right: 65,
                top: 45,
                child: Icon(
                  Icons.spa_outlined,
                  size: 35,
                  color: verdeLima.withValues(alpha: 0.35),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      _construirLogo(),
                      const SizedBox(height: 15),
                      Text(
                        'Dale la Vuelta',
                        style: estilo.copyWith(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Todo merece una segunda oportunidad',
                        style: estilo.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circuloDecorativo(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }

  // ------------------------------------------
  // LOGO
  // ------------------------------------------

  Widget _construirLogo() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFF83A98B),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: verdeBosque,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: verdeLima,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: verdeBosque, size: 24),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // FORMULARIO
  // ------------------------------------------

  Widget _construirFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E8E2), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2420).withValues(alpha: 0.09),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Qué bueno tenerte de vuelta!',
              style: estilo.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: texto,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Inicia sesión y descubre nuevas oportunidades.',
              style: estilo.copyWith(fontSize: 12, color: textoSecundario),
            ),

            const SizedBox(height: 27),

            // CORREO
            _construirEtiqueta('Correo electrónico'),

            const SizedBox(height: 9),

            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,

              // BLOQUEAR ESPACIOS
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],

              style: estilo.copyWith(
                fontSize: 13,
                color: texto,
                fontWeight: FontWeight.w500,
              ),
              decoration: _decoracionInput(
                icono: Icons.email_outlined,
                hint: 'tu@correo.com',
              ),
              validator: (v) {
                final t = v ?? '';

                if (t.isEmpty) {
                  return 'Escribe tu correo';
                }

                if (RegExp(r'\s').hasMatch(t)) {
                  return 'El correo no debe contener espacios';
                }

                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);

                return ok ? null : 'Correo no válido';
              },
            ),

            const SizedBox(height: 19),

            // CONTRASEÑA
            _construirEtiqueta('Contraseña'),

            const SizedBox(height: 9),

            TextFormField(
              controller: _password,
              obscureText: _ocultar,

              // BLOQUEAR ESPACIOS
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],

              style: estilo.copyWith(
                fontSize: 13,
                color: texto,
                fontWeight: FontWeight.w500,
              ),
              decoration: _decoracionInput(
                icono: Icons.lock_outline_rounded,
                hint: 'Ingresa tu contraseña',
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _ocultar = !_ocultar;
                    });
                  },
                  icon: Icon(
                    _ocultar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: textoSecundario,
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Escribe tu contraseña';
                }

                if (RegExp(r'\s').hasMatch(v)) {
                  return 'La contraseña no debe contener espacios';
                }

                if (v.length < 6) {
                  return 'Mínimo 6 caracteres';
                }

                return null;
              },
            ),

            const SizedBox(height: 27),

            // BOTÓN PRINCIPAL
            _construirBoton(),

            const SizedBox(height: 17),

            // REGISTRO
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: estilo.copyWith(
                      fontSize: 12,
                      color: textoSecundario,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegistroScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Crear cuenta',
                      style: estilo.copyWith(
                        fontSize: 12,
                        color: verdeBosque,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------
  // ETIQUETAS
  // ------------------------------------------

  Widget _construirEtiqueta(String titulo) {
    return Text(
      titulo,
      style: estilo.copyWith(
        color: texto,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ------------------------------------------
  // INPUTS PERSONALIZADOS
  // ------------------------------------------

  InputDecoration _decoracionInput({
    required IconData icono,
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: estilo.copyWith(
        color: const Color(0xFF9AA49C),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: fondoInput,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(9),
        child: Container(
          width: 35,
          height: 35,
          decoration: const BoxDecoration(
            color: verdeLima,
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: verdeBosque, size: 18),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 57, minHeight: 52),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
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
        borderSide: const BorderSide(color: verdeBosque, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  // ------------------------------------------
  // BOTÓN DE INICIO DE SESIÓN
  // ------------------------------------------

  Widget _construirBoton() {
    return Container(
      width: double.infinity,
      height: 53,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [verdeBosque, verdeClaro],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: verdeBosque.withValues(alpha: 0.30),
            blurRadius: 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _entrar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Iniciar sesión',
                style: estilo.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // INSIGNIA ECOLÓGICA
  // ------------------------------------------

  Widget _construirInsignia() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: verdeLima.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: verdeLima.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, color: verdeBosque, size: 18),
          const SizedBox(width: 8),
          Text(
            'Pequeñas acciones, grandes cambios',
            style: estilo.copyWith(
              color: verdeBosque,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------
// CURVA INFERIOR DE LA CABECERA
// ------------------------------------------

class CurvaInferiorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 35);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 25,
      size.width,
      size.height - 35,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
