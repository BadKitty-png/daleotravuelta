import 'package:flutter/material.dart';

class DaleColores {
  static const verdeBosque = Color(0xFF3D7050);
  static const verdeClaro = Color(0xFF4F8A65);
  static const verdeLima = Color(0xFFC2DA8D);
  static const ambar = Color(0xFFD4AF37);
  static const crema = Color(0xFFF7F8F5);
  static const blanco = Color(0xFFFFFFFF);
  static const carbon = Color(0xFF1E2420);
  static const grisMusgo = Color(0xFF5C6660);
  static const borde = Color(0xFFE4E8E2);
}

/// Logotipo compartido: círculos concéntricos y una hoja en el centro.
class LogoDaleVuelta extends StatelessWidget {
  final double size;
  final Color color;

  const LogoDaleVuelta({super.key, this.size = 76, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35), width: 2),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.65), width: 2),
            ),
          ),
          Container(
            width: size * 0.46,
            height: size * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.16),
            ),
            child: Icon(Icons.eco_rounded, color: color, size: size * 0.30),
          ),
        ],
      ),
    );
  }
}

/// Decoraciones orgánicas para dar continuidad visual a la aplicación.
class DecoracionOrganica extends StatelessWidget {
  const DecoracionOrganica({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 22,
            child: Icon(
              Icons.eco_outlined,
              size: 54,
              color: Colors.white.withOpacity(0.13),
            ),
          ),
          Positioned(
            top: 78,
            right: 92,
            child: Icon(
              Icons.autorenew_rounded,
              size: 38,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 24,
            child: Icon(
              Icons.spa_outlined,
              size: 42,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
