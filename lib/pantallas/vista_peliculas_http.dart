import 'package:flutter/material.dart';
import '../servicios/servicio_apis_http.dart';

class VistaPeliculasHttp extends StatefulWidget {
  final ServicioApisHttp servicio;
  const VistaPeliculasHttp({super.key, required this.servicio});

  @override
  State<VistaPeliculasHttp> createState() => _VistaPeliculasHttpState();
}

class _VistaPeliculasHttpState extends State<VistaPeliculasHttp> {
  String _animo = 'Emocionado';
  int _genreId = 28;
  late Future<List<PeliculaRemota>> _futurePeliculas;

  final Map<String, int> _generosPorAnimo = const {
    'Emocionado': 28,
    'Tranquilo': 16,
    'Divertido': 35,
    'Reflexivo': 878,
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futurePeliculas = widget.servicio.fetchPeliculasTmdb(
      estadoAnimo: _animo,
      genreId: _genreId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              for (final entry in _generosPorAnimo.entries)
                ChoiceChip(
                  label: Text(entry.key),
                  selected: _animo == entry.key,
                  onSelected: (_) {
                    setState(() {
                      _animo = entry.key;
                      _genreId = entry.value;
                      _cargar();
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PeliculaRemota>>(
            future: _futurePeliculas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('API TMDB: \${snapshot.error}'),
                  ),
                );
              }
              final peliculas = snapshot.data ?? const [];
              if (peliculas.isEmpty) {
                return const Center(child: Text('Sin resultados de TMDB'));
              }
              return ListView.builder(
                itemCount: peliculas.length,
                itemBuilder: (context, index) {
                  final p = peliculas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: p.posterUrl.isEmpty
                          ? const Icon(Icons.movie)
                          : Image.network(
                              p.posterUrl,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                      title: Text(p.titulo),
                      subtitle: Text(p.sinopsis, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
