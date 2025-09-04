import 'package:bee_movies/shared/widget/panel.dart';
import 'package:flutter/material.dart';
import 'peliculas_screen.dart';
import 'series_screen.dart';
import 'anime_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  // Solo las pantallas navegables (Menu no navega)
  final List<Widget> _screens = const [
    PeliculasScreen(),
    SeriesScreen(),
    AnimeScreen(),
  ];

  void _onNavTap(int index) {
    if (index == 3) {
      // “Menu” solo abre el panel izquierdo
      _scaffoldKey.currentState?.openDrawer();
      return; // no cambiamos currentIndex
    }
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // Panel lateral izquierdo
      drawer: const AppPanelDrawer(),

      // Solo se abre con el tab “Menu” (no con gesto)
      drawerEnableOpenDragGesture: false,

      // SIN AppBar
      extendBody: true,

      // Protege del notch/status bar
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(index: currentIndex, children: _screens),
      ),

      // Bottom Navigation con efecto vidrio
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(25),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: currentIndex, // 0..2
                onTap: _onNavTap,
                selectedItemColor: Theme.of(context).colorScheme.secondary,
                unselectedItemColor: Colors.white70,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.movie),
                    label: 'Películas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.live_tv),
                    label: 'Series',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_emotions),
                    label: 'Anime',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Menu', // abre el Drawer
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
