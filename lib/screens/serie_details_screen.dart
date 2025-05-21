import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importa el paquete
import '../models/serie_models.dart'; // Importa tus modelos
import '../services/serie_service.dart'; // Importa tu servicio
import 'chewie_player_screen.dart';

class SerieDetailsScreen extends StatefulWidget {
  final int serieId;

  const SerieDetailsScreen({super.key, required this.serieId});

  @override
  State<SerieDetailsScreen> createState() => _SerieDetailsScreenState();
}

class _SerieDetailsScreenState extends State<SerieDetailsScreen> {
  // Estado para la conexión a internet
  bool _isConnected = true; // Asumimos conexión al inicio, luego verificamos
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  // Variable para los detalles de la serie
  // Usamos ? para que pueda ser null inicialmente
  Future<SerieFullDetails>? _serieDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Inicia la comprobación de conectividad y la escucha de cambios
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    // La carga inicial de datos se realizará en _updateConnectionStatus
    // una vez que se determine el estado inicial de la conexión.
  }

  @override
  void dispose() {
    // Cancela la suscripción para evitar fugas de memoria
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Método para verificar la conexión inicial
  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      // Si hay un error al verificar (raro), asumimos sin conexión
      if (mounted) {
        setState(() {
          _isConnected = false;
          // Opcional: Asignar un Future.error si quieres que FutureBuilder lo maneje
          // _serieDetailsFuture = Future.error("Error al verificar conectividad: $e");
        });
      }
      return;
    }
    // Llama al método para actualizar el estado y potencialmente cargar datos
    return _updateConnectionStatus(result);
  }

  // Método para actualizar el estado de la conexión y cargar datos si es necesario
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    // Verifica si hay conexión a través de móvil, wifi o ethernet
    final bool currentlyConnected = result.any(
      (res) =>
          res == ConnectivityResult.mobile ||
          res == ConnectivityResult.wifi ||
          res == ConnectivityResult.ethernet,
    );

    // Solo actualiza el estado y carga datos si la conexión ha cambiado
    if (mounted && _isConnected != currentlyConnected) {
      setState(() {
        _isConnected = currentlyConnected;
        // Si la conexión se restablece, intenta cargar los datos
        if (_isConnected) {
          _fetchSerieDetailsData();
        } else {
          // Si se pierde la conexión, puedes establecer _serieDetailsFuture a null
          // para que el FutureBuilder ya no muestre los datos viejos
          // o dejar que el widget _buildNoConnectionWidget lo maneje completamente.
          // Si lo pones a null, necesitas verificar !snapshot.hasData en FutureBuilder.
          _serieDetailsFuture = null; // Opcional: limpia los datos viejos
        }
      });
    } else if (mounted && currentlyConnected && _serieDetailsFuture == null) {
      // Caso: Estaba inicialmente desconectado, ahora está conectado y no se han cargado los datos
      _fetchSerieDetailsData();
    } else if (mounted && !currentlyConnected && _serieDetailsFuture != null) {
      // Caso: La conexión se acaba de perder, limpiar el future para mostrar no conectado
      setState(() {
        _serieDetailsFuture = null;
      });
    }
  }

  // Método para cargar los detalles de la serie
  void _fetchSerieDetailsData() {
    // Solo carga si está montado y HAY conexión
    if (mounted && _isConnected) {
      setState(() {
        // Asigna el Future retornado por el servicio
        _serieDetailsFuture = SerieService().getSerieDetails(widget.serieId);
      });
    }
    // Si no hay conexión, _isConnected será false y se mostrará el widget de no conexión.
    // No necesitamos lanzar un error específico aquí desde la pantalla.
  }

  // Widget para mostrar cuando no hay conexión
  Widget _buildNoConnectionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color:
                Theme.of(
                  context,
                ).colorScheme.secondary, // Puedes usar el color de error
          ),
          const SizedBox(height: 16.0),
          Text(
            "Sin conexión a Internet",

            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(
                0.7,
              ), // Color de texto semi-transparente
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Intenta reconfirmar conexión y cargar datos
              _initConnectivity().then((_) {
                if (_isConnected) {
                  // Si después de verificar hay conexión, intenta cargar
                  _fetchSerieDetailsData();
                } else {
                  // Opcional: Mostrar un mensaje temporal si sigue sin conexión
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aún sin conexión. Intenta de nuevo.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white60),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles de la Serie")),
      // *** CONTROL PRINCIPAL CON _isConnected ***
      body:
          _isConnected // Si HAY conexión, muestra el FutureBuilder
              ? FutureBuilder<SerieFullDetails>(
                // Usamos _serieDetailsFuture que se actualiza en _fetchSerieDetailsData
                future: _serieDetailsFuture,
                builder: (context, snapshot) {
                  // El FutureBuilder ahora maneja:
                  // 1. Estado de carga
                  // 2. Errores *no relacionados con la falta de conexión* (ej. 404 de la API, error de parseo)
                  //    La falta de conexión A NIVEL DE RED es manejada por el `_isConnected ? ... : ...` externo.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Asegúrate de que _serieDetailsFuture no sea null aquí si quieres mostrar carga
                    // Podría ser null si la conexión se perdió y el future se limpió.
                    if (_serieDetailsFuture == null) {
                      return _buildNoConnectionWidget(); // Si el future es null, muestra no conectado
                    }
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Maneja errores del servicio (errores API, parseo, fallos de red *durante* la llamada)
                    debugPrint(
                      'DEBUG: Error en FutureBuilder: ${snapshot.error}',
                    );
                    // Puedes verificar si el error es un SocketException u otro error de red
                    // como fallback, aunque _isConnected debería prevenir la mayoría de casos.
                    // Si el error.toString() indica algo como SocketException o Failed host lookup,
                    // podrías volver a mostrar el widget de no conexión, aunque idealmente
                    // el `_isConnected ? ... : ...` ya lo habría interceptado.
                    // Por simplicidad, mostramos el error tal cual si FutureBuilder lo captura.
                    return Center(child: Text('REGISTRO SIN INFORMACION'));
                  } else if (!snapshot.hasData) {
                    // Esto puede ocurrir si el future es null (ej. si la conexión se acaba de perder)
                    // o si el future completó sin datos (aunque nuestra API siempre devuelve content/seasons o error).
                    // Si _serieDetailsFuture se puso a null al perder conexión, esto lo captura.
                    if (!_isConnected) {
                      return _buildNoConnectionWidget();
                    }
                    // Si hasData es false *con* conexión, es un caso inesperado o API sin datos.
                    return const Center(
                      child: Text('No se encontraron datos para esta serie.'),
                    );
                  } else {
                    // Si los datos se cargaron correctamente (y hay conexión)
                    final serieDetails = snapshot.data!;
                    final content = serieDetails.content;
                    final seasons = serieDetails.seasons;

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // --- Sección de Contenido General ---
                        if (content.contentCover.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              content.contentCover,
                              fit: BoxFit.contain,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16.0),
                        Text(
                          content.contentTitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Año: ${content.contentYear} | Género: ${content.contentGender}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24.0),

                        // --- Sección de Temporadas y Episodios ---
                        Center(
                          child: Text(
                            'TEMPORADAS',
                            style: TextStyle(
                              // <--- Aquí creas un TextStyle
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary, // <--- Y aquí especificas el color
                              // Puedes añadir otros estilos si quieres, como fontSize, fontWeight, etc.
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Column(
                          children:
                              seasons.map((season) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: ExpansionTile(
                                    title: Text(season.seasonName),
                                    children:
                                        season.episodes.map((episode) {
                                          return ListTile(
                                            leading: const Icon(
                                              Icons.play_circle_fill,
                                            ),
                                            title: Text(
                                              'Episodio ${episode.episodeNumber}: ${episode.episodeName}',
                                            ),
                                            onTap: () {
                                              // TODO: Implementar la reproducción del episodio
                                              // print(
                                              //   'Reproducir: ${episode.episodeUrl}',
                                              // );
                                              // Asegúrate de verificar la conexión antes de intentar reproducir también
                                              // if(_isConnected) { /* reproducir */ } else { /* mostrar mensaje */ }
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ChewiePlayerScreen(
                                                            videoUrl:
                                                                episode
                                                                    .episodeUrl,
                                                          ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    );
                  }
                },
              )
              // Si NO HAY conexión, muestra el widget de "Sin conexión"
              : _buildNoConnectionWidget(),
    );
  }
}
