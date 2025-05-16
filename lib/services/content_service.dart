import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';

class ContentService {
  // URL de la API (ajústalo a tu caso)
  final String apiUrl = 'https://peliculas.between-bytes.tech/api/v1/content';

  // Método para obtener las series
  Future<List<Content>> fetchContent() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, parseamos el JSON
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Content.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load series');
      }
    } catch (error) {
      throw Exception('Error al obtener las series: $error');
    }
  }
}
