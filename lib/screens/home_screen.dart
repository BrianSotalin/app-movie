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
  int currentIndex = 0;

  final List<Widget> _screens = const [
    PeliculasScreen(),
    SeriesScreen(),
    AnimeScreen(),
  ];

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: IndexedStack(index: currentIndex, children: _screens),
  //     bottomNavigationBar: BottomNavigationBar(
  //       currentIndex: currentIndex,
  //       onTap: (index) => setState(() => currentIndex = index),
  //       items: const [
  //         BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Películas'),
  //         BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Series'),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.emoji_emotions),
  //           label: 'Anime',
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ← permite que el body se muestre debajo del navbar
      body: IndexedStack(index: currentIndex, children: _screens),
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
                // border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: currentIndex,
                onTap: (index) => setState(() => currentIndex = index),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
