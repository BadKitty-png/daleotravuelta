import 'package:flutter/material.dart';

import '../widgets/estilo_app.dart';
import 'publicar_datos_screen.dart';

class PublicarTipoScreen extends StatefulWidget {
  const PublicarTipoScreen({super.key});

  @override
  State<PublicarTipoScreen> createState() => _PublicarTipoScreenState();
}

class _PublicarTipoScreenState extends State<PublicarTipoScreen> {
  String _modalidad = 'Donar';

  final List<String> _categorias = [
    'Bicicletas',
    'Electrónicas',
    'Muebles',
    'Ropa',
    'Otros productos',
  ];

  String _categoria = 'Bicicletas';

  Color _colorModalidad(String modalidad) {
    switch (modalidad) {
      case 'Donar':
        return DaleColores.verdeBosque;
      case 'Vender':
        return DaleColores.verdeClaro;
      default:
        return DaleColores.ambar;
    }
  }

  IconData _iconoModalidad(String modalidad) {
    switch (modalidad) {
      case 'Vender':
        return Icons.sell_outlined;
      case 'Donar':
        return Icons.volunteer_activism_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
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
          'Publicar un objeto',
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
          _encabezado(),
          const SizedBox(height: 24),

          const Text(
            '¿Qué quieres hacer?',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Elige cómo quieres darle una nueva vuelta a tu objeto.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 13,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 14),

          for (final modalidad in ['Vender', 'Donar', 'Intercambiar'])
            _tarjetaModalidad(modalidad),

          const SizedBox(height: 24),

          const Text(
            'Categoría del objeto',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: _categoria,
            decoration: _decoracion(
              'Selecciona una categoría',
              Icons.category_outlined,
            ),
            items: _categorias
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (valor) {
              if (valor != null) {
                setState(() => _categoria = valor);
              }
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Fotografías',
            style: TextStyle(
              color: DaleColores.carbon,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Agrega al menos 3 fotos para mostrar tu objeto.',
            style: TextStyle(
              color: DaleColores.grisMusgo,
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 9),
                    height: 100,
                    decoration: BoxDecoration(
                      color: DaleColores.verdeLima.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: DaleColores.borde),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo_outlined,
                          color: DaleColores.verdeBosque,
                          size: 27,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Foto ${i + 1}',
                          style: const TextStyle(
                            color: DaleColores.grisMusgo,
                            fontSize: 11,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 30),

          _boton(
            texto: 'Continuar',
            icono: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicarDatosScreen(
                    categoria: _categoria,
                    modalidad: _modalidad,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.all(18),
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
                      'Publica y comparte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ayuda a que un objeto encuentre un nuevo hogar.',
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
              const SizedBox(width: 8),
              const LogoDaleVuelta(size: 62),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaModalidad(String modalidad) {
    final seleccionada = _modalidad == modalidad;
    final color = _colorModalidad(modalidad);

    return GestureDetector(
      onTap: () => setState(() => _modalidad = modalidad),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionada ? color.withOpacity(0.09) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: seleccionada ? color : DaleColores.borde,
            width: seleccionada ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconoModalidad(modalidad), color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                modalidad,
                style: const TextStyle(
                  color: DaleColores.carbon,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Icon(
              seleccionada ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: seleccionada ? color : DaleColores.grisMusgo,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracion(String texto, IconData icono) {
    return InputDecoration(
      labelText: texto,
      prefixIcon: Icon(icono, color: DaleColores.verdeBosque),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DaleColores.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: DaleColores.verdeBosque,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _boton({
    required String texto,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono),
        label: Text(
          texto,
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
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
