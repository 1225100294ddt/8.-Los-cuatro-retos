import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cuatro_retos_http_real/servicios/servicio_apis_http.dart';

void main() {
  // Prueba 1
  test('Prueba 1: construye URL de Cataas y parsea respuesta HTTP de TMDB con poster_path', () async {
    final mockClient = MockClient((request) async {
      expect(request.url.host, 'api.themoviedb.org');
      expect(request.url.path, '/3/discover/movie');
      return http.Response(
        jsonEncode({
          'results': [
            {
              'id': 569094,
              'title': 'Spider-Man: A Través del Spider-Verso',
              'overview': 'Aventura multiversal.',
              'poster_path': '/iiZZdoigEYBc6aR77fN57qk65.jpg',
            }
          ]
        }),
        200,
      );
    });

    final servicio = ServicioApisHttp(client: mockClient, tmdbApiKey: 'test_key');
    final catUri = servicio.buildCataasUri('Cuando compila');
    expect(catUri.toString(), contains('https://cataas.com/cat/says/Cuando%20compila'));

    final pelis = await servicio.fetchPeliculasTmdb(estadoAnimo: 'Emocionado', genreId: 28);
    expect(pelis.length, 1);
    expect(pelis.first.posterUrl, 'https://image.tmdb.org/t/p/w500/iiZZdoigEYBc6aR77fN57qk65.jpg');
  });

  // Prueba 2
  test('Prueba 2: parsea respuesta HTTP de OpenWeatherMap para Dolores Hidalgo', () async {
    final mockClient = MockClient((request) async {
      expect(request.url.host, 'api.openweathermap.org');
      expect(request.url.path, '/data/2.5/weather');
      return http.Response(
        jsonEncode({
          'name': 'Dolores Hidalgo',
          'main': {'temp': 23.5, 'humidity': 36},
          'weather': [
            {'description': 'cielo claro'}
          ],
        }),
        200,
      );
    });

    final servicio = ServicioApisHttp(client: mockClient, openWeatherApiKey: 'ow_key');
    final clima = await servicio.fetchClimaOpenWeather(lat: 21.1561, lon: -100.9318);
    expect(clima.ciudad, 'Dolores Hidalgo');
    expect(clima.temperaturaC, 23.5);
    expect(clima.descripcion, 'cielo claro');
  });

  // Prueba 3
  test('Prueba 3: consulta HTTP de CoinGecko y calcula fracciones en USD', () async {
    final mockClient = MockClient((request) async {
      expect(request.url.host, 'api.coingecko.com');
      expect(request.url.path, '/api/v3/simple/price');
      return http.Response(
        jsonEncode({
          'bitcoin': {'usd': 90000.0},
          'ethereum': {'usd': 3000.0},
          'solana': {'usd': 200.0},
        }),
        200,
      );
    });

    final servicio = ServicioApisHttp(client: mockClient);
    final precios = await servicio.fetchPreciosCoinGeckoUsd();
    expect(precios['BITCOIN'], 90000.0);
    expect(servicio.calcularUnidades(900.0, precios['BITCOIN']!), closeTo(0.01, 1e-9));
    expect(servicio.calcularUnidades(600.0, precios['SOLANA']!), closeTo(3.0, 1e-9));
  });
}
