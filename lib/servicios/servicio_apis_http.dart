import 'dart:convert';
import 'package:http/http.dart' as http;

class PeliculaRemota {
  final int id;
  final String titulo;
  final String estadoAnimo;
  final String sinopsis;
  final String posterUrl;

  const PeliculaRemota({
    required this.id,
    required this.titulo,
    required this.estadoAnimo,
    required this.sinopsis,
    required this.posterUrl,
  });

  factory PeliculaRemota.fromTmdbJson(Map<String, dynamic> json, String estadoAnimo) {
    final posterPath = (json['poster_path'] as String?) ?? '';
    return PeliculaRemota(
      id: json['id'] as int,
      titulo: (json['title'] as String?) ?? 'Sin título',
      estadoAnimo: estadoAnimo,
      sinopsis: (json['overview'] as String?) ?? '',
      posterUrl: posterPath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w500\$posterPath',
    );
  }
}

class ClimaRemoto {
  final String ciudad;
  final double temperaturaC;
  final String descripcion;
  final int humedad;

  const ClimaRemoto({
    required this.ciudad,
    required this.temperaturaC,
    required this.descripcion,
    required this.humedad,
  });

  factory ClimaRemoto.fromOpenWeatherJson(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List<dynamic>?) ?? const [];
    final firstWeather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final mainMap = (json['main'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return ClimaRemoto(
      ciudad: (json['name'] as String?) ?? 'Dolores Hidalgo',
      temperaturaC: ((mainMap['temp'] as num?) ?? 23.0).toDouble(),
      descripcion: (firstWeather['description'] as String?) ?? 'Despejado',
      humedad: ((mainMap['humidity'] as num?) ?? 38).toInt(),
    );
  }
}

class ServicioApisHttp {
  final http.Client client;
  final String tmdbApiKey;
  final String openWeatherApiKey;

  ServicioApisHttp({
    http.Client? client,
    this.tmdbApiKey = '',
    this.openWeatherApiKey = '',
  }) : client = client ?? http.Client();

  Uri buildCataasUri(String texto) {
    final limpio = texto.trim().isEmpty ? 'Miau' : texto.trim();
    final encoded = Uri.encodeComponent(limpio);
    return Uri.parse('https://cataas.com/cat/says/\$encoded?fontSize=36');
  }

  Future<List<PeliculaRemota>> fetchPeliculasTmdb({
    String estadoAnimo = 'Todos',
    int genreId = 28,
  }) async {
    final uri = Uri.https('api.themoviedb.org', '/3/discover/movie', {
      'api_key': tmdbApiKey,
      'language': 'es-MX',
      'with_genres': '\$genreId',
    });

    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error TMDB HTTP \${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final results = (decoded['results'] as List<dynamic>?) ?? const [];
    return results
        .map((item) => PeliculaRemota.fromTmdbJson(item as Map<String, dynamic>, estadoAnimo))
        .toList();
  }

  Future<ClimaRemoto> fetchClimaOpenWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': '\$lat',
      'lon': '\$lon',
      'appid': openWeatherApiKey,
      'units': 'metric',
      'lang': 'es',
    });

    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error OpenWeather HTTP \${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    return ClimaRemoto.fromOpenWeatherJson(decoded);
  }

  Future<Map<String, double>> fetchPreciosCoinGeckoUsd() async {
    final uri = Uri.https('api.coingecko.com', '/api/v3/simple/price', {
      'ids': 'bitcoin,ethereum,solana',
      'vs_currencies': 'usd',
    });

    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error CoinGecko HTTP \${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final precios = <String, double>{};
    decoded.forEach((coinId, value) {
      if (value is Map<String, dynamic> && value['usd'] is num) {
        precios[coinId.toUpperCase()] = (value['usd'] as num).toDouble();
      }
    });
    return precios;
  }

  double calcularUnidades(double montoUsd, double precioUsd) {
    if (montoUsd <= 0 || precioUsd <= 0) return 0.0;
    return montoUsd / precioUsd;
  }
}
