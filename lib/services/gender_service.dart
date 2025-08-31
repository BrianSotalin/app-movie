import 'dart:convert';
import 'package:bee_movies/screens/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import '../models/gender_model.dart';

class GenderService {
  Future<List<Gender>> fetchGenders() async {
    final url = Uri.parse('$baseUrl/gender');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Gender.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}
