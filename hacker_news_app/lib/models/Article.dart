// import 'dart:convert';

// class Article {
//   final int id;
//   final String title;
//   final String by;
//   final String? url;
//   final List<int>? kids;
//   final int? descendants;
//   bool isFavorite;

//   Article({
//     required this.id,
//     required this.title,
//     required this.by,
//     this.url,
//     this.kids,
//     this.descendants,
//     this.isFavorite = false,
//   });

//   // Constructeur pour créer un Article depuis les données JSON de l'API
//   factory Article.fromJson(Map<String, dynamic> json) {
//     return Article(
//       id: json['id'],
//       title: json['title'] ?? '',
//       by: json['by'] ?? '',
//       url: json['url'],
//       kids: json['kids'] != null ? List<int>.from(json['kids']) : null,
//       descendants: json['descendants'],
//       isFavorite: false, // Par défaut false, API ne fournit pas ce champ
//     );
//   }

//   // Constructeur pour créer un Article depuis la base locale (SQLite)
//   factory Article.fromMap(Map<String, dynamic> map) {
//     return Article(
//       id: map['id'],
//       title: map['title'],
//       by: map['by'],
//       url: map['url'],
//       kids: map['kids'] != null ? List<int>.from(jsonDecode(map['kids'])) : null,
//       descendants: map['descendants'],
//       isFavorite: map['isFavorite'] == 1, // Conversion int vers bool
//     );
//   }

//   // Convertir un Article en Map pour SQLite (to insert/update)
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'by': by,
//       'url': url,
//       'kids': kids != null ? jsonEncode(kids) : null,
//       'descendants': descendants,
//       'isFavorite': isFavorite ? 1 : 0, // Conversion bool vers int
//     };
//   }
// }
import 'dart:convert';

class Article {
  final int id;
  final String title;
  final String by;
  final String? url;
  final List<int>? kids;
  final int? descendants;
  int _isFavorite;

  Article({
    required this.id,
    required this.title,
    required this.by,
    this.url,
    this.kids,
    this.descendants,
    int isFavorite = 0,
  }) : _isFavorite = isFavorite;

  bool get isFavorite => _isFavorite == 1;

  set isFavorite(bool value) {
    _isFavorite = value ? 1 : 0;
  }

  // Création d'un Article depuis JSON API (Map<String, dynamic>)
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      by: json['by'] ?? '',
      url: json['url'],
      kids: json['kids'] != null ? List<int>.from(json['kids']) : null,
      descendants: json['descendants'],
      isFavorite: 0,
    );
  }

  // Création d'un Article depuis la BDD (Map<String, dynamic>)
  factory Article.fromMap(Map<String, dynamic> map) {
    List<int>? kidsList;
    if (map['kids'] != null) {
      try {
        // kids est stocké en JSON string en base, on le decode
        kidsList = (jsonDecode(map['kids']) as List<dynamic>).map((e) => e as int).toList();
      } catch (e) {
        kidsList = null;
      }
    }

    return Article(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      title: map['title'] ?? '',
      by: map['by'] ?? '',
      url: map['url'],
      kids: kidsList,
      descendants: map['descendants'] is int
          ? map['descendants']
          : (map['descendants'] != null ? int.tryParse(map['descendants'].toString()) : null),
      isFavorite: map['isFavorite'] is int
          ? map['isFavorite']
          : int.tryParse(map['isFavorite'].toString()) ?? 0,
    );
  }

  // Conversion d'un Article en Map pour stockage en BDD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'by': by,
      'url': url,
      'kids': kids != null ? jsonEncode(kids) : null,
      'descendants': descendants,
      'isFavorite': _isFavorite,
    };
  }
}
