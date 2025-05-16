class Content {
  final int id;
  final String title;
  final String type;
  final String cover;
  final int year;
  final String gender;

  Content({
    required this.id,
    required this.title,
    required this.type,
    required this.cover,
    required this.year,
    required this.gender,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['content_id'],
      title: json['content_title'],
      type: json['content_type'],
      cover: json['content_cover'],
      year: json['content_year'],
      gender: json['content_gender'],
    );
  }
}
