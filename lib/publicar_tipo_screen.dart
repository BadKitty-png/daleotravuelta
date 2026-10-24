import 'package:flutter/material.dart';
import 'publicar_datos_screen.dart';

/// Pantalla 2 — Detalle de usuario: modalidad, categoría y fotos
class PublicarTipoScreen extends StatefulWidget {
  const PublicarTipoScreen({super.key});

  @override
  State<PublicarTipoScreen> createState() => _PublicarTipoScreenState();
}

class _PublicarTipoScreenState extends State<PublicarTipoScreen> {
  String _modalidad = 'Donar';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('¿Qué quieres hacer?', style: t),
          RadioGroup<String>(
            groupValue: _modalidad,
            onChanged: (v) => setState(() => _modalidad = v!),
            child: const Column(
              children: [
                RadioListTile<String>(title: Text('Vender'), value: 'Vender'),
                RadioListTile<String>(title: Text('Donar'), value: 'Donar'),
                RadioListTile<String>(title: Text('Intercambiar'), value: 'Intercambiar'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Categoría'),
            initialValue: 'Bicicletas',
            items: const ['Bicicletas', 'Electrónicas', 'Muebles', 'Ropa']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(height: 24),
          Text('Fotos (mínimo 3)', style: t),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 90,
                    color: cs.surfaceContainerHighest,
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PublicarDatosScreen()),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
