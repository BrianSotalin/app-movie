import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'dart:io'; // Import for SocketException
import '../shared/widget/no_connection_widget.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';
import '../screens/serie_details_screen.dart'; // Assuming SerieDetailsScreen can display any Content type
import '../models/gender_model.dart';
import '../services/gender_service.dart';
import '../shared/widget/detail_card.dart';

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

  List<Gender> _categories = [];

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
      _fetchCategories();
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

  //metodo para cargar generos
  void _fetchCategories() async {
    try {
      final genders = await GenderService().fetchGenders();
      setState(() {
        _categories = [Gender(id: 0, name: 'ALL'), ...genders];
      });
    } catch (e) {
      // Puedes mostrar un mensaje o dejar la lista vacía
    }
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

  @override
  Widget build(BuildContext context) {
    final sortedCategories = [..._categories]
      ..sort((a, b) => a.name.compareTo(b.name));
    final abcCategories =
        _categories.where((category) {
            if (_selectedCategory == 'ALL') {
              return category.name != 'ALL';
            }
            return category.name == _selectedCategory;
          }).toList()
          ..sort(
            (a, b) => a.name.compareTo(b.name),
          ); // <-- esta es la línea clave
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtrar por género',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items:
                              sortedCategories.map((gender) {
                                return DropdownMenuItem<String>(
                                  value: gender.name,
                                  child: Text(gender.name),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;

                                Navigator.pop(context); // Cierra el menú
                                _filterAnime(); // Aplica el filtro
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
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
                      return NoConnectionWidget(
                        onRetry: () {
                          _initConnectivity().then((_) {
                            if (_isConnected) {
                              _fetchAnimeData(); // Asegúrate de tener esta función disponible
                            }
                          });
                        },
                      );
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
                                        abcCategories
                                            .where((category) {
                                              // Si está seleccionado 'ALL', mostramos todas las categorías (excepto 'ALL' misma si existe)
                                              if (_selectedCategory == 'ALL') {
                                                return category.name != 'ALL';
                                              }
                                              // Solo mostrar la categoría seleccionada
                                              return category.name ==
                                                  _selectedCategory;
                                            })
                                            .map((category) {
                                              final animeInCategory =
                                                  _filteredAnime
                                                      .where(
                                                        (movie) =>
                                                            movie.gender ==
                                                            category.name,
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
                                                          ? category
                                                              .name // Show category name if ALL is selected
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
                                                        return DetailCard(
                                                          title: anime.title,
                                                          coverUrl: anime.cover,
                                                          gender: anime.gender,
                                                          year: '${anime.year}',
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
              : NoConnectionWidget(
                onRetry: () {
                  _initConnectivity().then((_) {
                    if (_isConnected) {
                      _fetchAnimeData(); // Asegúrate de tener esta función disponible
                    }
                  });
                },
              ), // Show "No connection" widget
    );
  }
}
