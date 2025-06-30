class Article {
  final int id;
  final String title;
  final String by;
  final int? descendants;
  final String? url;
  final List<int>? kids;
  final int time;
  bool isFavorite;

  Article({
    required this.id,
    required this.title,
    required this.by,
    required this.time,
    this.descendants,
    this.url,
    this.kids,
    this.isFavorite = false,
  });

  /// Création à partir du JSON de l’API
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? 'Sans titre',
      by: json['by'] ?? 'Inconnu',
      time: json['time'],
      descendants: json['descendants'],
      url: json['url'],
      kids: json['kids'] != null ? List<int>.from(json['kids']) : [],
    );
  }

  /// Conversion pour insertion dans SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'by': by,
      'time': time,
      'descendants': descendants,
      'url': url,
      'kids': kids?.join(','), // SQLite ne gère pas les listes, on stocke en string
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  /// Récupération depuis SQLite
  factory Article.fromMap(Map<String, dynamic> map) {
  return Article(
    id: map['id'],
    title: map['title'],
    by: map['by'],
    time: map['time'],
    descendants: map['descendants'],
    url: map['url'],
    kids: map['kids'] != null && map['kids'] != ''
        ? (map['kids'] as String).split(',').map((e) => int.parse(e)).toList()
        : [],
    isFavorite: map['isFavorite'] == 1,
  );
}

}
