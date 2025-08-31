import 'dart:convert';
import 'package:bee_movies/screens/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieService {
  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movie'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Error al cargar películas');
    }
  }
}
