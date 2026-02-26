class MovieDTO {
  final int movieId;
  final String title;
  final int year;
  final String urlCover;
  final String urlVideo;
  final int genderId;
  final String gender;

  MovieDTO({
    required this.movieId,
    required this.title,
    required this.year,
    required this.urlCover,
    required this.urlVideo,
    required this.genderId,
    required this.gender,
  });

  factory MovieDTO.fromJson(Map<String, dynamic> json) {
    return MovieDTO(
      movieId: json['movie_id'],
      title: json['title'],
      year: json['year'],
      urlCover: json['url_cover'],
      urlVideo: json['url_video'],
      genderId: json['gender_id'],
      gender: json['gender'],
    );
  }
}
