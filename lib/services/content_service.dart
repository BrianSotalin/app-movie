import 'dart:convert';
import 'package:bee_movies/screens/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';

class ContentService {
  Future<List<Content>> fetchContent() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/content'));

      if (response.statusCode == 200) {
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
