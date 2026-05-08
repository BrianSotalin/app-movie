# 🎬 App Movie - Flutter

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

Una aplicación móvil moderna y elegante para los amantes del cine. Explora las últimas tendencias, busca tus títulos favoritos y conoce los detalles de las películas y su reparto en tiempo real.

## ✨ Características

- **Cartelera Dinámica:** Swiper interactivo con las películas que están actualmente en cines.
- **Scroll Infinito:** Explora la sección de películas populares sin interrupciones.
- **Detalles Completos:** Información detallada sobre sinopsis, puntuación y reparto.
- **Búsqueda Avanzada:** Motor de búsqueda integrado para localizar cualquier película en la base de datos de TMDB.
- **Optimización de UI:** Uso de placeholders y skeletons mientras se cargan las imágenes.

## 🛠️ Tecnologías Utilizadas

- **Framework:** [Flutter](https://flutter.dev/)
- **Lenguaje:** [Dart](https://dart.dev/)
- **Gestión de Estado:** `Provider` para un manejo eficiente de la data.
- **API:** [The Movie Database (TMDB)](https://www.themoviedb.org/)
- **Networking:** Paquete `http` para peticiones REST.

## 📦 Instalación

Sigue estos pasos para ejecutar el proyecto en tu entorno local:

1. **Clona el repositorio:**
   ```bash
   git clone [https://github.com/BrianSotalin/app-movie.git](https://github.com/BrianSotalin/app-movie.git)

2. **Obtén las dependencias:**
   ```bash
   cd app-movie
   flutter pub get

3. **Configura tu API Key:**
Busca el archivo de configuración o provider donde se encuentra la variable _apiKey y reemplázala con tu llave personal de TMDB.

Ejecuta la app:
   ```bash
flutter run
