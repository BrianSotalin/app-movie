import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gender_model.dart';

class GenderService {
  Future<List<Gender>> fetchGenders() async {
    final url = Uri.parse('https://peliculas.between-bytes.tech/api/v1/gender');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Gender.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}
