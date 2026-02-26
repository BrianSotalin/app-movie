class Season {
  final int id;
  final String name;

  Season({required this.id, required this.name});

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(id: json['season_id'], name: json['season_name']);
  }
}
