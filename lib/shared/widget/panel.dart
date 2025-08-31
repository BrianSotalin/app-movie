import 'package:bee_movies/screens/home_screen.dart';
import 'package:flutter/material.dart';

/// Úsalo así en tu Scaffold:
/// drawer: AppPanelDrawer(
///   onAddMovie: () {},
///   onAddSeries: () {},
///   onAddAnime: () {},
///   onChangeLanguage: () {},
///   onToggleTheme: () {},
///   onLogout: () {},
/// )
class AppPanelDrawer extends StatelessWidget {
  final VoidCallback? onAddMovie;
  final VoidCallback? onAddSeries;
  final VoidCallback? onAddAnime;
  final VoidCallback? onChangeLanguage;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onLogout;

  final String versionText;
  final bool isDark;
  final String languageFlag; // ej: '🇪🇸'

  const AppPanelDrawer({
    super.key,
    this.onAddMovie,
    this.onAddSeries,
    this.onAddAnime,
    this.onChangeLanguage,
    this.onToggleTheme,
    this.onLogout,
    this.versionText = '1.0.4',
    this.isDark = true,
    this.languageFlag = '🇪🇸',
  });

  @override
  Widget build(BuildContext context) {
    //final iconColor = color ?? Theme.of(context).colorScheme.secondary;

    const bg = Color(0xFF111425);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Between\nBytes\nSoftware',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),

              // Botones (Home/About opcionales de ejemplo)
              const SizedBox(height: 10),
              _pillFilled(
                'About',
                Icons.info_outline,
                onTap: () => onAddSeries?.call(),
              ),
              const SizedBox(height: 10),

              _pillFilled(
                'Add Movie',
                Icons.movie,
                onTap: () => onAddMovie?.call(),
              ),
              const SizedBox(height: 10),
              _pillFilled(
                'Add Series',
                Icons.live_tv,
                onTap: () => onAddSeries?.call(),
              ),
              const SizedBox(height: 10),
              _pillFilled(
                'Add Anime',
                Icons.emoji_emotions,
                onTap: () => onAddAnime?.call(),
              ),

              const SizedBox(height: 20),

              // Idioma / Tema
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _circleIcon(
                      child: Text(
                        languageFlag,
                        style: const TextStyle(fontSize: 18),
                      ),
                      onTap: () => onChangeLanguage?.call(),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 14, color: Colors.white24),
                    const SizedBox(width: 12),
                    _circleIcon(
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.wb_sunny,
                        color: isDark ? Colors.white70 : Colors.amber,
                      ),
                      onTap: () => onToggleTheme?.call(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'Follow US',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Lista de personas con redes
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: const [
                    _PersonSocial(
                      name: 'Daniel Sotalin',
                      role: 'Desarrollador',
                      icons: [
                        Icons.camera_alt_outlined,
                        Icons.code,
                        Icons.public,
                      ],
                    ),
                    SizedBox(height: 12),
                    _PersonSocial(
                      name: 'Jorge Loor',
                      role: 'Desarrollador',
                      icons: [
                        Icons.camera_alt_outlined,
                        Icons.code,
                        Icons.public,
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Version $versionText',
                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                ),
              ),
              const SizedBox(height: 12),

              // Logout
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFFE53935),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => onLogout?.call(),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== helpers de estilo ====

  static Widget _pillFilled(String text, IconData icon, {VoidCallback? onTap}) {
    return SizedBox(
      height: 42,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 120, 225, 110),
          foregroundColor: Color(0xFFFFFFFF),
          shape: const StadiumBorder(),
        ),
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }

  static Widget _circleIcon({required Widget child, VoidCallback? onTap}) {
    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _PersonSocial extends StatelessWidget {
  final String name;
  final String role;
  final List<IconData> icons;

  const _PersonSocial({
    required this.name,
    required this.role,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(role, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children:
              icons
                  .map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkResponse(
                        onTap: () {}, // aquí pegas links/acciones reales
                        radius: 18,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(i, size: 18, color: Colors.white70),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
