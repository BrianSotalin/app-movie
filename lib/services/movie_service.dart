import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieService {
  final String apiUrl =
      'https://peliculas.between-bytes.tech/api/v1/movie'; // ← pon tu URL real aquí

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Error al cargar películas');
    }
  }
}
