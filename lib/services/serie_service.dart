import 'dart:convert';
import 'package:bee_movies/screens/helpers/base_url.dart';
import 'package:http/http.dart' as http;
import '../models/serie_models.dart'; // Importa tus modelos

class SerieService {
  Future<SerieFullDetails> getSerieDetails(int serieId) async {
    final url = Uri.parse(
      '$baseUrl/content/full_content/$serieId',
    ); // Construye la URL completa

    try {
      final response = await http.get(url);

      //debugPrint('DEBUG API CALL: Response status code: ${response.statusCode}');
      //debugPrint('DEBUG API CALL: Response body (partial): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SerieFullDetails.fromJson(jsonResponse);
      } else {
        // Si la respuesta no fue 200, pero sí hubo conexión para llegar al server
        throw Exception(
          'Error al cargar detalles de la serie. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Esto atrapará errores de la llamada http si la conexión se pierde durante la llamada
      // o si hay otros problemas de red/servidor no HTTP.
      // debugPrint('DEBUG API CALL: Excepción http/red capturada: $e');
      // Si ya lanzamos 'NO_INTERNET_CONNECTION', no queremos lanzar otra excepción aquí.
      // Pero si el error original no fue 'NO_INTERNET_CONNECTION', lanzamos un error genérico de fallo de conexión.
      // Aunque la verificación inicial ya debería cubrir la mayoría de casos sin conexión.
      if (e.toString().contains('NO_INTERNET_CONNECTION')) {
        rethrow; // Re-lanza la excepción de no conexión si ya la teníamos
      } else {
        throw Exception(
          'Fallo de conexión o del servidor: $e',
        ); // Error genérico
      }
    }
  }
}
