import 'package:flutter/material.dart';
import 'pantallas/vista_clima_http.dart';
import 'pantallas/vista_cripto_http.dart';
import 'pantallas/vista_gatos_http.dart';
import 'pantallas/vista_peliculas_http.dart';
import 'servicios/servicio_apis_http.dart';

void main() {
  runApp(const AppRetosHttp());
}

class AppRetosHttp extends StatelessWidget {
  const AppRetosHttp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4 Retos · HTTP Real',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ContenedorRetosHttp(),
    );
  }
}

class ContenedorRetosHttp extends StatefulWidget {
  const ContenedorRetosHttp({super.key});

  @override
  State<ContenedorRetosHttp> createState() => _ContenedorRetosHttpState();
}

class _ContenedorRetosHttpState extends State<ContenedorRetosHttp> {
  final ServicioApisHttp _servicio = ServicioApisHttp(
    tmdbApiKey: String.fromEnvironment('TMDB_API_KEY'),
    openWeatherApiKey: String.fromEnvironment('OPENWEATHER_API_KEY'),
  );
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = <Widget>[
      VistaPeliculasHttp(servicio: _servicio),
      VistaGatosHttp(servicio: _servicio),
      VistaClimaHttp(servicio: _servicio),
      VistaCriptoHttp(servicio: _servicio),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('4 Retos con APIs HTTP')),
      body: pantallas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.movie), label: 'Películas'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Gatos'),
          NavigationDestination(icon: Icon(Icons.wb_sunny), label: 'Clima'),
          NavigationDestination(icon: Icon(Icons.currency_bitcoin), label: 'Cripto'),
        ],
      ),
    );
  }
}
