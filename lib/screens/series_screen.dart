import 'package:flutter/material.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';
//import 'chewie_player_screen.dart';

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
    _seriesFuture = ContentService().fetchContent().then(
      (allContent) => allContent.where((item) => item.type == 'SERIE').toList(),
    );

    _seriesFuture.then((series) {
      setState(() {
        _allSeries = series;
        _filteredSeries = series;
      });
    });
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Series')),
      body: FutureBuilder<List<Content>>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final allContent = await ContentService().fetchContent();
              final series =
                  allContent.where((item) => item.type == 'SERIE').toList();
              setState(() {
                _allSeries = series;
                _filterSeries();
              });
            },

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar Serie',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterSeries();
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        _categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                                _filterSeries();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow:
                                    isSelected
                                        ? [
                                          const BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                        : [],
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
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children:
                        (_selectedCategory == 'ALL'
                                ? _categories.where((c) => c != 'ALL')
                                : [_selectedCategory])
                            .map((category) {
                              final seriesInCategory =
                                  _filteredSeries
                                      .where(
                                        (serie) =>
                                            category == 'ALL' ||
                                            serie.gender.toUpperCase() ==
                                                category,
                                      )
                                      .toList();

                              if (seriesInCategory.isEmpty) return SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      category,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: seriesInCategory.length,
                                      itemBuilder: (context, index) {
                                        final serie = seriesInCategory[index];
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: 140,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: Image.network(
                                                    serie.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            bottom:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          serie.title,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        Text(
                                                          '${serie.gender} • ${serie.year}',
                                                          style: const TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 12,
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
      ),
    );
  }
}
