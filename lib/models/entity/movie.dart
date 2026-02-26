class Movie {
  final int movieId;
  final String title;
  final int year;
  final String urlCover;
  final String urlVideo;
  final int genderId;

  Movie({
    required this.movieId,
    required this.title,
    required this.year,
    required this.urlCover,
    required this.urlVideo,
    required this.genderId,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieId: json['movie_id'],
      title: json['title'],
      year: json['year'],
      urlCover: json['url_cover'],
      urlVideo: json['url_video'],
      genderId: json['gender_id'],
    );
  }
}
