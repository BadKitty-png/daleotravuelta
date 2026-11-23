import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  static const Color verde = Color(0xFF3D7050);
  static const Color verdeClaro = Color(0xFF4F8A65);
  static const Color lima = Color(0xFFC2DA8D);
  static const Color ambar = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [verde, verdeClaro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // CÍRCULOS DECORATIVOS
            Positioned(top: -100, right: -80, child: _circulo(290)),
            Positioned(bottom: -100, left: -90, child: _circulo(270)),
            Positioned(
              top: 120,
              left: 30,
              child: Icon(
                Icons.eco_outlined,
                color: Colors.white.withValues(alpha: 0.12),
                size: 55,
              ),
            ),
            Positioned(
              bottom: 140,
              right: 35,
              child: Icon(
                Icons.autorenew_rounded,
                color: Colors.white.withValues(alpha: 0.12),
                size: 65,
              ),
            ),

            // CONTENIDO
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _construirLogo(),

                    const SizedBox(height: 28),

                    const Text(
                      'Dale la Vuelta',
                      style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Dar una segunda vida a las cosas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 45),

                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: lima,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Pequeñas acciones, grandes cambios',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // DETALLE INFERIOR
            Positioned(
              bottom: 35,
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: lima, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    'REUTILIZAR  •  REPARAR  •  COMPARTIR',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
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

  Widget _circulo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
          width: 2,
        ),
      ),
    );
  }

  Widget _construirLogo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 145,
            height: 145,
            decoration: const BoxDecoration(
              color: Color(0xFF83A98B),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 105,
            height: 105,
            decoration: const BoxDecoration(
              color: verde,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: lima,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: verde, size: 38),
          ),
          Positioned(
            right: 2,
            bottom: 15,
            child: Container(
              width: 23,
              height: 23,
              decoration: const BoxDecoration(
                color: ambar,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}
