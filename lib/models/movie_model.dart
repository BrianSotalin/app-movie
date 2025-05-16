class Movie {
  final int id;
  final String title;
  final int year;
  final String cover;
  final String url;
  final String gender;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.cover,
    required this.url,
    required this.gender,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['movie_id'],
      title: json['movie_title'],
      year: json['movie_year'],
      cover: json['movie_cover'],
      url: json['movie_url'],
      gender: json['gender'],
    );
  }
}
