import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Pantalla de carga (Splash)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recycling, size: 110, color: cs.onPrimary),
            const SizedBox(height: 12),
            Text(
              'Dale Otra Vuelta',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Dar una segunda vida a las cosas',
                style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.85))),
            const SizedBox(height: 32),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: cs.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
