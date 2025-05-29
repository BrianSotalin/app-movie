import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'dart:io'; // Import for SocketException
import '../shared/widget/no_connection_widget.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';
import '../screens/serie_details_screen.dart';
import '../models/gender_model.dart';
import '../services/gender_service.dart';
import '../shared/widget/detail_card.dart';
import '../shared/widget/appbar_menu.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late Future<List<Content>> _seriesFuture;
  List<Content> _allSeries = [];
  List<Content> _filteredSeries = [];
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  bool _isConnected = true; // Track internet connectivity
  // Estado para la conexión a internet
  //bool _isConnected = true; // Asumimos conexión al inicio, luego verificamos
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

      _fetchSeriesData();
    } else {
      // Si no hay conexión al inicio, _moviesFuture puede ser un futuro que ya completó con error
      // o simplemente no mostrar nada hasta que haya conexión.
      // Para evitar un error de late initialization, lo asignamos a un futuro que no hará nada
      // o que ya tiene un error predefinido.
      _seriesFuture = Future.value(
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
    if (_isConnected && _allSeries.isEmpty) {
      _fetchSeriesData();
    }
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

  /// Fetches series data from the ContentService.
  /// This method is responsible for updating `_seriesFuture` and `_allSeries`.
  Future<void> _fetchSeriesData() async {
    setState(() {
      _seriesFuture = ContentService()
          .fetchContent()
          .then(
            (allContent) =>
                allContent.where((item) => item.type == 'SERIE').toList(),
          )
          .then((series) {
            _allSeries = series;
            _filterSeries(); // Apply filters to the newly fetched data
            return series;
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

  /// Filters the series based on the current search query and selected category.
  void _filterSeries() {
    setState(() {
      _filteredSeries =
          _allSeries.where((serie) {
            final matchesSearch = serie.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchesCategory =
                _selectedCategory == 'ALL' ||
                serie.gender.toUpperCase() == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Series'),
        actions: [
          PopupFilterMenu(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (newValue) {
              setState(() {
                _selectedCategory = newValue;
                _filterSeries();
              });
            },
          ),
        ],
      ),
      body:
          _isConnected // Check connectivity status here
              ? FutureBuilder<List<Content>>(
                future: _seriesFuture,
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
                              _fetchSeriesData(); // Asegúrate de tener esta función disponible
                            }
                          });
                        },
                      );
                    }
                    // For other types of errors, display a generic error message
                    return Center(
                      child: Text(
                        'Error al cargar series: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                        ), // Highlight error
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If no data after loading (and no error), or data is empty
                    return const Center(
                      child: Text(
                        'No hay series disponibles.',
                        style: TextStyle(color: Colors.amber),
                      ),
                    );
                  }

                  // If we reach here, there is connection and data
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_isConnected) {
                        await _fetchSeriesData(); // Call the method that updates _seriesFuture
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
                              hintText: 'Buscar Serie',
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
                              _filterSeries();
                            },
                          ),
                        ),

                        const SizedBox(height: 8),
                        Expanded(
                          child:
                              _filteredSeries.isEmpty && _searchQuery.isNotEmpty
                                  ? const Center(
                                    child: Text(
                                      'No se encontraron series con ese filtro.',
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
                                              final seriesInCategory =
                                                  _filteredSeries
                                                      .where(
                                                        (movie) =>
                                                            movie.gender ==
                                                            category.name,
                                                      )
                                                      .toList();

                                              if (seriesInCategory.isEmpty) {
                                                return const SizedBox.shrink(); // Don't show category header if no series
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
                                                          seriesInCategory
                                                              .length,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        final serie =
                                                            seriesInCategory[index];
                                                        return DetailCard(
                                                          title: serie.title,
                                                          coverUrl: serie.cover,
                                                          gender: serie.gender,
                                                          year: '${serie.year}',
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => SerieDetailsScreen(
                                                                      serieId:
                                                                          serie
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
                      _fetchSeriesData(); // Asegúrate de tener esta función disponible
                    }
                  });
                },
              ), // Show "No connection" widget
    );
  }
}
