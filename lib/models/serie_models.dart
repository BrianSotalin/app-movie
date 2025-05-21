// import 'dart:convert';

// Modelo principal que envuelve toda la respuesta
class SerieFullDetails {
  final Content content;
  final List<Season> seasons;

  SerieFullDetails({required this.content, required this.seasons});

  factory SerieFullDetails.fromJson(Map<String, dynamic> json) {
    return SerieFullDetails(
      content: Content.fromJson(json['content']),
      seasons:
          (json['seasons'] as List)
              .map((seasonJson) => Season.fromJson(seasonJson))
              .toList(),
    );
  }
}

// Modelo para la información general de la serie
class Content {
  final int contentId;
  final String contentTitle;
  final String contentType;
  final String contentCover;
  final int contentYear;
  final String contentGender;

  Content({
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
    required this.contentCover,
    required this.contentYear,
    required this.contentGender,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      contentId: json['content_id'],
      contentTitle: json['content_title'],
      contentType: json['content_type'],
      contentCover: json['content_cover'],
      contentYear: json['content_year'],
      contentGender: json['content_gender'],
    );
  }
}

// Modelo para una temporada
class Season {
  final int seasonId;
  final String seasonName;
  final List<Episode> episodes;

  Season({
    required this.seasonId,
    required this.seasonName,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonId: json['season_id'],
      seasonName: json['season_name'],
      episodes:
          (json['episodes'] as List)
              .map((episodeJson) => Episode.fromJson(episodeJson))
              .toList(),
    );
  }
}

// Modelo para un episodio
class Episode {
  final int episodeId;
  final int episodeNumber;
  final String episodeName;
  final String episodeUrl;
  // El campo 'season' parece estar vacío en tu ejemplo JSON,
  // pero lo incluimos por si acaso, aunque su utilidad es cuestionable aquí.
  final String season;

  Episode({
    required this.episodeId,
    required this.episodeNumber,
    required this.episodeName,
    required this.episodeUrl,
    required this.season, // Puedes ajustar esto si no es necesario
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeId: json['episode_id'],
      episodeNumber: json['episode_number'],
      episodeName: json['episode_name'],
      episodeUrl: json['episode_url'],
      season: json['season'] ?? '', // Usar ?? '' para manejar posibles nulos
    );
  }
}
