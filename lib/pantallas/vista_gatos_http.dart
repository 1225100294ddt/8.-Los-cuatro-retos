import 'package:flutter/material.dart';
import '../servicios/servicio_apis_http.dart';

class VistaGatosHttp extends StatefulWidget {
  final ServicioApisHttp servicio;
  const VistaGatosHttp({super.key, required this.servicio});

  @override
  State<VistaGatosHttp> createState() => _VistaGatosHttpState();
}

class _VistaGatosHttpState extends State<VistaGatosHttp> {
  final TextEditingController _ctrl = TextEditingController(text: 'Hola Cataas');
  String _frase = 'Hola Cataas';
  int _nonce = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUri = widget.servicio.buildCataasUri(_frase);
    final urlConNonce = '\$baseUri&t=\$_nonce';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _ctrl,
          decoration: const InputDecoration(
            labelText: 'Texto para Cataas API',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => setState(() {
            _frase = _ctrl.text;
            _nonce++;
          }),
          child: const Text('Solicitar gato a Cataas'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 280,
          child: Image.network(
            urlConNonce,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => const Center(child: Text('No se pudo cargar imagen de Cataas')),
          ),
        ),
      ],
    );
  }
}
