import 'package:flutter/material.dart';
import '../servicios/servicio_apis_http.dart';

class VistaClimaHttp extends StatefulWidget {
  final ServicioApisHttp servicio;
  const VistaClimaHttp({super.key, required this.servicio});

  @override
  State<VistaClimaHttp> createState() => _VistaClimaHttpState();
}

class _VistaClimaHttpState extends State<VistaClimaHttp> {
  // Coordenadas de Dolores Hidalgo, Guanajuato por defecto
  double _lat = 21.1561;
  double _lon = -100.9318;
  late Future<ClimaRemoto> _futureClima;

  @override
  void initState() {
    super.initState();
    _cargarClima();
  }

  void _cargarClima() {
    _futureClima = widget.servicio.fetchClimaOpenWeather(lat: _lat, lon: _lon);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => setState(() {
                _lat = 21.1561;
                _lon = -100.9318;
                _cargarClima();
              }),
              child: const Text('Dolores Hidalgo'),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _lat = 21.0190;
                _lon = -101.2574;
                _cargarClima();
              }),
              child: const Text('Guanajuato'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<ClimaRemoto>(
          future: _futureClima,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('OpenWeather: \${snapshot.error}');
            }
            final clima = snapshot.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clima.ciudad, style: Theme.of(context).textTheme.titleLarge),
                    Text('\${clima.temperaturaC.toStringAsFixed(1)} °C'),
                    Text(clima.descripcion),
                    Text('Humedad: \${clima.humedad}%'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
