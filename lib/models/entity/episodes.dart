class Episode {
  final int episodeId;
  final int number;
  final String name;
  final String urlVideo;
  final int seasonId;
  final int contentId;

  Episode({
    required this.episodeId,
    required this.number,
    required this.name,
    required this.urlVideo,
    required this.seasonId,
    required this.contentId,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeId: json['episode_id'],
      number: json['number'],
      name: json['name'],
      urlVideo: json['url_video'],
      seasonId: json['season_id'],
      contentId: json['content_id'],
    );
  }
}
