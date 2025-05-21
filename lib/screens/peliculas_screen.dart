import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importa el paquete
import '../models/movie_model.dart';
import '../services/movie_service.dart';
import 'helpers/chewie_player_screen.dart';

class PeliculasScreen extends StatefulWidget {
  const PeliculasScreen({super.key});

  @override
  State<PeliculasScreen> createState() => _PeliculasScreenState();
}

class _PeliculasScreenState extends State<PeliculasScreen> {
  // Estado para la conexión a internet
  bool _isConnected = true; // Asumimos conexión al inicio, luego verificamos
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  // Variables para las películas
  late Future<List<Movie>> _moviesFuture;
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'FAMILIAR',
    'DRAMA',
    'ACCION',
    'TERROR',
    'COMEDIA',
  ];

  @override
  void initState() {
    super.initState();
    // Inicia la comprobación de conectividad y la escucha de cambios
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    // Inicializa _moviesFuture con un futuro vacío o una carga inicial si es necesario,
    // pero la carga principal se hará después de verificar la conexión.
    // Si _isConnected es true después de _initConnectivity, llamamos a _fetchMoviesData.
    // Si no, _moviesFuture podría quedar sin inicializar hasta que haya conexión.
    // Es mejor inicializarlo aquí con una función que dependa de _isConnected.
    if (_isConnected) {
      _fetchMoviesData();
    } else {
      // Si no hay conexión al inicio, _moviesFuture puede ser un futuro que ya completó con error
      // o simplemente no mostrar nada hasta que haya conexión.
      // Para evitar un error de late initialization, lo asignamos a un futuro que no hará nada
      // o que ya tiene un error predefinido.
      _moviesFuture = Future.value(
        [],
      ); // O un futuro que resuelva a una lista vacía
      // o Future.error("Sin conexión inicial");
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Cancela la suscripción
    super.dispose();
  }

  // Método para verificar la conexión inicial
  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
      //print('Error al verificar conectividad: $e');
      return;
    }
    return _updateConnectionStatus(result);
  }

  // Método para actualizar el estado de la conexión y cargar datos si es necesario
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final bool currentlyConnected = result.any(
      (res) =>
          res == ConnectivityResult.mobile ||
          res == ConnectivityResult.wifi ||
          res == ConnectivityResult.ethernet,
    );

    if (mounted) {
      // Verifica si el widget sigue montado
      if (_isConnected != currentlyConnected) {
        setState(() {
          _isConnected = currentlyConnected;
        });
      }
      // Si hay conexión y las películas no se han cargado (o se quiere recargar)
      if (_isConnected && (_allMovies.isEmpty)) {
        _fetchMoviesData();
      } else if (!_isConnected) {
        // Si no hay conexión, puedes limpiar las películas o mostrar las cacheadas si las tienes.
        // Por ahora, simplemente actualizamos el estado, y el FutureBuilder manejará el error
        // o el widget de "Sin conexión" se mostrará.
        setState(() {
          // Opcionalmente, si quieres que _moviesFuture refleje el error de conexión inmediatamente:
          // _moviesFuture = Future.error("Sin conexión a Internet");
        });
      }
    }
  }

  // Método para cargar las películas
  void _fetchMoviesData() {
    if (mounted && _isConnected) {
      // Solo carga si está conectado y montado
      setState(() {
        _moviesFuture = MovieService().fetchMovies();
        // El .then se maneja mejor dentro del FutureBuilder o si necesitas
        // hacer algo específico justo después de que los datos lleguen y antes de reconstruir.
        _moviesFuture
            .then((movies) {
              if (mounted) {
                setState(() {
                  _allMovies = movies;
                  _filterMovies(); // Aplica filtros iniciales si es necesario
                });
              }
            })
            .catchError((error) {
              // Si hay un error al cargar películas (incluso con conexión), actualiza el estado
              // para que FutureBuilder pueda mostrar el error.
              if (mounted) {
                setState(() {
                  // _moviesFuture ya contendrá el error, pero podemos forzar reconstrucción
                  // si es necesario o manejar de otra forma.
                  //print("Error en _fetchMoviesData: $error");
                });
              }
            });
      });
    } else if (mounted && !_isConnected) {
      // Si se intenta cargar sin conexión, actualiza _moviesFuture para reflejarlo
      setState(() {
        _moviesFuture = Future.error("Sin conexión a Internet");
      });
    }
  }

  void _filterMovies() {
    if (!mounted) return;
    setState(() {
      if (_selectedCategory == 'ALL' && _searchQuery.isEmpty) {
        _filteredMovies = List.from(_allMovies);
      } else {
        _filteredMovies =
            _allMovies.where((movie) {
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  movie.title.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              final matchesCategory =
                  _selectedCategory == 'ALL' ||
                  movie.gender == _selectedCategory;
              return matchesSearch && matchesCategory;
            }).toList();
      }
    });
  }

  Widget _buildNoConnectionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.wifi_off, // Logo de no wifi
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Sin conexión a Internet', // Mensaje
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Intenta recargar los datos o verificar la conexión de nuevo
              _initConnectivity().then((_) {
                if (_isConnected) {
                  _fetchMoviesData();
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white60),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Películas')),
      body:
          _isConnected // Comprueba el estado de la conexión aquí
              ? FutureBuilder<List<Movie>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Podrías tener un error de red (aunque _isConnected lo cubre) u otro error de API
                    // Si el error es específicamente por falta de conexión (lo cual _isConnected debería prevenir aquí),
                    // podrías mostrar _buildNoConnectionWidget() también, o un mensaje de error más general.
                    // Por ahora, mostramos el error genérico si _isConnected es true pero aún hay error.
                    // print("Error en FutureBuilder: ${snapshot.error}");
                    // Si el error es específicamente por falta de conexión (que _isConnected debería haber manejado),
                    // podrías devolver _buildNoConnectionWidget() aquí como fallback.
                    // O simplemente el mensaje de error que viene del snapshot.
                    // Si el error es debido a SocketException o similar, es probable que sea un problema de red
                    // que _isConnected no capturó a tiempo o la llamada falló antes del cambio de estado.
                    if (snapshot.error.toString().contains('SocketException') ||
                        snapshot.error.toString().contains(
                          'Failed host lookup',
                        ) ||
                        snapshot.error.toString().toLowerCase().contains(
                          'sin conexión',
                        )) {
                      return _buildNoConnectionWidget(); // Muestra el widget de no conexión si el error es de red
                    }
                    return Center(
                      child: Text(
                        'Error al cargar películas: ${snapshot.error}',
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Si no hay datos después de cargar (y no hay error)
                    return const Center(
                      child: Text('No hay películas disponibles.'),
                    );
                  }

                  // Si llegamos aquí, hay conexión y datos (o snapshot.data es una lista vacía procesable)
                  // _allMovies ya debería estar actualizado por el .then de _moviesFuture,
                  // o puedes usar snapshot.data directamente.
                  // Es más seguro usar _allMovies y _filteredMovies que ya se actualizan en setState.
                  // Si _allMovies no se llena en el .then, usa snapshot.data
                  // if (_allMovies.isEmpty && snapshot.hasData) {
                  //   _allMovies = snapshot.data!;
                  //   _filterMovies(); // Asegúrate de que los filtros se aplican con los nuevos datos
                  // }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_isConnected) {
                        _fetchMoviesData(); // Llama al método que actualiza _moviesFuture
                        await _moviesFuture; // Espera a que el nuevo futuro se complete
                      } else {
                        // Opcional: muestra un Snackbar o no hagas nada si no hay conexión
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sin conexión para refrescar.'),
                          ),
                        );
                      }
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar Película',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[800],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _searchQuery = value;
                                    _filterMovies();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  _categories.map((category) {
                                    final isSelected =
                                        _selectedCategory == category;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                          _filterMovies();
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            if (isSelected)
                                              const BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child:
                              _filteredMovies.isEmpty && _searchQuery.isNotEmpty
                                  ? const Center(
                                    child: Text(
                                      'No se encontraron películas con ese filtro.',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  )
                                  : ListView(
                                    children:
                                        _categories
                                            .where(
                                              (
                                                category,
                                              ) => // Solo muestra categorías que tienen películas filtradas
                                                  _selectedCategory == 'ALL' ||
                                                  _selectedCategory == category,
                                            )
                                            .map((category) {
                                              final moviesInCategory =
                                                  _filteredMovies
                                                      .where(
                                                        (movie) =>
                                                            _selectedCategory ==
                                                                    'ALL'
                                                                ? movie.gender ==
                                                                    category
                                                                : true,
                                                      )
                                                      .where(
                                                        (movie) =>
                                                            _selectedCategory !=
                                                                    'ALL'
                                                                ? movie.gender ==
                                                                    _selectedCategory
                                                                : true,
                                                      )
                                                      .toList();

                                              if (moviesInCategory.isEmpty) {
                                                return const SizedBox.shrink(); // No muestra nada si no hay películas para esta categoría
                                              }

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    child: Text(
                                                      category == 'ALL' &&
                                                              _selectedCategory ==
                                                                  'ALL'
                                                          ? "Todas las películas"
                                                          : category, // Ajuste para cuando 'ALL' está seleccionado
                                                      style:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .titleLarge,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 220,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          moviesInCategory
                                                              .length,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final movie =
                                                            moviesInCategory[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => ChewiePlayerScreen(
                                                                      videoUrl:
                                                                          movie
                                                                              .url,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: 140,
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                ),
                                                            child: Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        16,
                                                                      ),
                                                                  child: Image.network(
                                                                    movie.cover,
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    height:
                                                                        double
                                                                            .infinity,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                    errorBuilder: (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) {
                                                                      return Container(
                                                                        color:
                                                                            Colors.grey[800],
                                                                        child: const Center(
                                                                          child: Icon(
                                                                            Icons.movie_creation_outlined,
                                                                            color:
                                                                                Colors.white70,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    loadingBuilder: (
                                                                      BuildContext
                                                                      context,
                                                                      Widget
                                                                      child,
                                                                      ImageChunkEvent?
                                                                      loadingProgress,
                                                                    ) {
                                                                      if (loadingProgress ==
                                                                          null)
                                                                        return child;
                                                                      return Center(
                                                                        child: CircularProgressIndicator(
                                                                          value:
                                                                              loadingProgress.expectedTotalBytes !=
                                                                                      null
                                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                                      loadingProgress.expectedTotalBytes!
                                                                                  : null,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .black54,
                                                                      borderRadius: BorderRadius.vertical(
                                                                        bottom:
                                                                            Radius.circular(
                                                                              16,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          8,
                                                                        ),
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          movie
                                                                              .title,
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        Text(
                                                                          '${movie.gender} • ${movie.year}',
                                                                          style: const TextStyle(
                                                                            color:
                                                                                Colors.white70,
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            })
                                            .toList(),
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              )
              : _buildNoConnectionWidget(), // Muestra el widget de "Sin conexión"
    );
  }
}
