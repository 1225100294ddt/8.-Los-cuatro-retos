import 'package:flutter/material.dart';
import '../servicios/servicio_apis_http.dart';

class VistaCriptoHttp extends StatefulWidget {
  final ServicioApisHttp servicio;
  const VistaCriptoHttp({super.key, required this.servicio});

  @override
  State<VistaCriptoHttp> createState() => _VistaCriptoHttpState();
}

class _VistaCriptoHttpState extends State<VistaCriptoHttp> {
  final TextEditingController _usdCtrl = TextEditingController(text: '250');
  double _montoUsd = 250.0;
  late Future<Map<String, double>> _futurePrecios;

  @override
  void initState() {
    super.initState();
    _futurePrecios = widget.servicio.fetchPreciosCoinGeckoUsd();
  }

  @override
  void dispose() {
    _usdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _usdCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monto en USD',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            final p = double.tryParse(v.trim()) ?? 0.0;
            setState(() => _montoUsd = p < 0 ? 0.0 : p);
          },
        ),
        const SizedBox(height: 14),
        FutureBuilder<Map<String, double>>(
          future: _futurePrecios,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('CoinGecko: \${snapshot.error}');
            }
            final precios = snapshot.data ?? const {};
            return Column(
              children: [
                for (final entry in precios.entries)
                  ListTile(
                    title: Text(entry.key),
                    subtitle: Text('USD \${entry.value.toStringAsFixed(2)}'),
                    trailing: Text(
                      widget.servicio.calcularUnidades(_montoUsd, entry.value).toStringAsFixed(6),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
