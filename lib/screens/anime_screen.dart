import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'dart:io'; // Import for SocketException

import '../models/content_model.dart';
import '../services/content_service.dart';
import '../screens/serie_details_screen.dart'; // Assuming SerieDetailsScreen can display any Content type

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  late Future<List<Content>> _animeFuture;
  List<Content> _allAnime = [];
  List<Content> _filteredAnime = [];
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  bool _isConnected = true; // Track internet connectivity
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  final List<String> _categories = [
    'ALL',
    'FAMILIAR',
    'DRAMA',
    'ACCION',
    'TERROR',
    'COMEDIA',
    'AVENTURA',
  ];

  @override
  void initState() {
    super.initState();
    // Inicia la comprobación de conectividad y la escucha de cambios
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityStatus,
    );

    // Inicializa _moviesFuture con un futuro vacío o una carga inicial si es necesario,
    // pero la carga principal se hará después de verificar la conexión.
    // Si _isConnected es true después de _initConnectivity, llamamos a _fetchMoviesData.
    // Si no, _moviesFuture podría quedar sin inicializar hasta que haya conexión.
    // Es mejor inicializarlo aquí con una función que dependa de _isConnected.
    if (_isConnected) {
      _fetchAnimeData();
    } else {
      // Si no hay conexión al inicio, _moviesFuture puede ser un futuro que ya completó con error
      // o simplemente no mostrar nada hasta que haya conexión.
      // Para evitar un error de late initialization, lo asignamos a un futuro que no hará nada
      // o que ya tiene un error predefinido.
      _animeFuture = Future.value(
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
    return _updateConnectivityStatus(result);
  }

  /// Updates the connectivity status based on the provided results.
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet) ||
          results.contains(
            ConnectivityResult.vpn,
          ); // Added VPN for completeness
    });
    // If connection is restored, try to fetch content again
    if (_isConnected && _allAnime.isEmpty) {
      _fetchAnimeData();
    }
  }

  /// Fetches anime data from the ContentService.
  /// This method is responsible for updating `_animeFuture` and `_allAnime`.
  Future<void> _fetchAnimeData() async {
    setState(() {
      _animeFuture = ContentService()
          .fetchContent()
          .then(
            (allContent) =>
                allContent.where((item) => item.type == 'ANIME').toList(),
          )
          .then((animeList) {
            _allAnime = animeList;
            _filterAnime(); // Apply filters to the newly fetched data
            return animeList;
          })
          .catchError((error) {
            // Catch errors during content fetching, specifically network errors
            // print('Error fetching content: $error');
            if (error is SocketException ||
                error.toString().contains('Failed host lookup')) {
              setState(() {
                _isConnected =
                    false; // Explicitly set to false if network error during fetch
              });
            }
            throw error; // Re-throw the error so FutureBuilder can handle it
          });
    });
  }

  /// Filters the anime based on the current search query and selected category.
  void _filterAnime() {
    setState(() {
      _filteredAnime =
          _allAnime.where((anime) {
            final matchesSearch = anime.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchesCategory =
                _selectedCategory == 'ALL' ||
                anime.gender.toUpperCase() == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();
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
                  _fetchAnimeData();
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
      appBar: AppBar(title: const Text('Anime')),
      body:
          _isConnected // Check connectivity status here
              ? FutureBuilder<List<Content>>(
                future: _animeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Check for specific network-related errors
                    final errorString = snapshot.error.toString().toLowerCase();
                    if (errorString.contains('socketeexception') ||
                        errorString.contains('failed host lookup') ||
                        errorString.contains('sin conexión')) {
                      return _buildNoConnectionWidget(); // Show no connection widget if network error
                    }
                    // For other types of errors, display a generic error message
                    return Center(
                      child: Text(
                        'Error al cargar anime: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                        ), // Highlight error
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If no data after loading (and no error), or data is empty
                    return const Center(
                      child: Text(
                        'No hay anime disponible.',
                        style: TextStyle(color: Colors.amber),
                      ),
                    );
                  }

                  // If we reach here, there is connection and data
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_isConnected) {
                        await _fetchAnimeData(); // Call the method that updates _animeFuture
                      } else {
                        // Optional: show a Snackbar or do nothing if offline
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sin conexión para refrescar.'),
                          ),
                        );
                      }
                    },
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.secondary, // Refresh indicator color
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar Anime',
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
                              _filterAnime();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: SingleChildScrollView(
                            // Changed to SingleChildScrollView with Row
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
                                          _filterAnime();
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
                              _filteredAnime.isEmpty && _searchQuery.isNotEmpty
                                  ? const Center(
                                    child: Text(
                                      'No se encontraron anime con ese filtro.',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  )
                                  : ListView(
                                    children:
                                        _categories
                                            .where(
                                              (category) =>
                                                  _selectedCategory == 'ALL' ||
                                                  _selectedCategory == category,
                                            )
                                            .map((category) {
                                              final animeInCategory =
                                                  _filteredAnime
                                                      .where(
                                                        (anime) =>
                                                            _selectedCategory ==
                                                                    'ALL'
                                                                ? anime.gender
                                                                        .toUpperCase() ==
                                                                    category
                                                                : anime.gender
                                                                        .toUpperCase() ==
                                                                    _selectedCategory,
                                                      )
                                                      .toList();

                                              if (animeInCategory.isEmpty) {
                                                return const SizedBox.shrink(); // Don't show category header if no anime
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
                                                      _selectedCategory == 'ALL'
                                                          ? category // Show category name if ALL is selected
                                                          : _selectedCategory, // Show specific category title
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
                                                          animeInCategory
                                                              .length,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final anime =
                                                            animeInCategory[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => SerieDetailsScreen(
                                                                      serieId:
                                                                          anime
                                                                              .id,
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
                                                                    anime.cover,
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
                                                                      BuildContext
                                                                      context,
                                                                      Object
                                                                      error,
                                                                      StackTrace?
                                                                      stackTrace,
                                                                    ) {
                                                                      return Container(
                                                                        color:
                                                                            Colors.grey[800],
                                                                        child: const Center(
                                                                          child: Icon(
                                                                            Icons.broken_image, // Changed to broken_image icon
                                                                            color:
                                                                                Colors.white70,
                                                                            size:
                                                                                40,
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
                                                                          color:
                                                                              Theme.of(
                                                                                context,
                                                                              ).colorScheme.secondary,
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
                                                                          anime
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
                                                                          '${anime.gender} • ${anime.year}',
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
              : _buildNoConnectionWidget(), // Show "No connection" widget
    );
  }
}
