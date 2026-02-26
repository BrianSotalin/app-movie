import 'package:bee_movies/models/entity/episodes.dart';

class Content {
  final int contentId;
  final String title;
  final int type;
  final String urlCover;
  final int year;
  final int genderId;
  final int seasonId;
  final List<Episode> episodes;

  Content({
    required this.contentId,
    required this.title,
    required this.type,
    required this.urlCover,
    required this.year,
    required this.genderId,
    required this.seasonId,
    required this.episodes,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      contentId: json['contentId'],
      title: json['title'],
      type: json['type'],
      urlCover: json['urlCover'],
      year: json['year'],
      genderId: json['genderId'],
      seasonId: json['seasonId'],
      episodes:
          (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList(),
    );
  }
}
