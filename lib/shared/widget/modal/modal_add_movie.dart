import 'package:bee_movies/shared/widget/modal/modal_add_gender.dart';
import 'package:flutter/material.dart';

class MovieFormData {
  final String title;
  final int year;
  final String imageUrl;
  final String movieUrl;
  final String genre;

  MovieFormData({
    required this.title,
    required this.year,
    required this.imageUrl,
    required this.movieUrl,
    required this.genre,
  });
}

class ModalAddMovie extends StatefulWidget {
  final List<int>? years;
  final List<String>? genres;

  const ModalAddMovie({super.key, this.years, this.genres});

  @override
  State<ModalAddMovie> createState() => _ModalAddMovieState();
}

class _ModalAddMovieState extends State<ModalAddMovie> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _movieUrlCtrl = TextEditingController();

  late List<int> _years;
  late List<String> _genres;

  int? _selectedYear;
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().year;
    _years =
        widget.years ??
        List<int>.generate(now - 1950 + 1, (i) => now - i); // desc
    _genres =
        widget.genres ??
        const ['Acción', 'Aventura', 'Comedia', 'Drama', 'Terror', 'Sci-Fi'];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _imageUrlCtrl.dispose();
    _movieUrlCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _requiredUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final uri = Uri.tryParse(v.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https')))
      return 'URL inválida';
    return null;
  }

  // deco reutilizable
  InputDecoration _roundedInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _openAddGenre() async {
    // Capturamos el messenger ANTES del await (evita lint)
    final messenger = ScaffoldMessenger.of(context);

    final newGenre = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ModalAddGener(),
    );

    if (!mounted) return;

    if (newGenre == null || newGenre.isEmpty) return;

    final exists = _genres.any(
      (g) => g.toLowerCase().trim() == newGenre.toLowerCase().trim(),
    );

    if (exists) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ese género ya existe')),
      );
      return;
    }

    setState(() {
      _genres = [..._genres, newGenre];
      _selectedGenre = newGenre;
    });
  }

  void _save() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok || _selectedYear == null || _selectedGenre == null) {
      if (_selectedYear == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un año')));
      } else if (_selectedGenre == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona un género')));
      }
      return;
    }
    Navigator.of(context).pop(
      MovieFormData(
        title: _titleCtrl.text.trim(),
        year: _selectedYear!,
        imageUrl: _imageUrlCtrl.text.trim(),
        movieUrl: _movieUrlCtrl.text.trim(),
        genre: _selectedGenre!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Colors.white,
          width: 1,
        ), // borde del modal
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'AÑADIR PELÍCULAS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                // Separador bajo el título
                const SizedBox(height: 4),
                const Divider(height: 1, thickness: 1, color: Colors.white24),
                const SizedBox(height: 10),

                // Campos redondeados
                TextFormField(
                  controller: _titleCtrl,
                  validator: _required,
                  textInputAction: TextInputAction.next,
                  decoration: _roundedInputDecoration(context, 'TITULO'),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<int>(
                  initialValue: _selectedYear,
                  items:
                      _years
                          .map(
                            (y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text('$y'),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedYear = v),
                  decoration: _roundedInputDecoration(
                    context,
                    'SELECCIONA UN AÑO',
                  ),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _imageUrlCtrl,
                  validator: _requiredUrl,
                  textInputAction: TextInputAction.next,
                  decoration: _roundedInputDecoration(context, 'URL IMAGEN'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _movieUrlCtrl,
                  validator: _requiredUrl,
                  textInputAction: TextInputAction.done,
                  decoration: _roundedInputDecoration(context, 'URL PELICULA'),
                ),
                const SizedBox(height: 10),

                // Select Género + botón (+) unidos
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      // Select con bordes redondos SOLO a la izquierda
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGenre,
                          items:
                              _genres
                                  .map(
                                    (g) => DropdownMenuItem<String>(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => _selectedGenre = v),
                          decoration: const InputDecoration(
                            hintText: 'SELECCIONA UN GENERO',
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Botón (+) pegado a la derecha
                      Container(
                        width: 48,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA2CA8E),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          onPressed: _openAddGenre,
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Agregar género',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Botón GUARDAR con borde blanco
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA2CA8E),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    label: const Text(
                      'GUARDAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
