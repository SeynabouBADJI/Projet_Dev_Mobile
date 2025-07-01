class Comment {
  final int id;
  final String? by;
  final String? text;
  final List<int>? kids;

  Comment({required this.id, this.by, this.text, this.kids});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      by: json['by'],
      text: json['text'],
      kids: json['kids'] != null ? List<int>.from(json['kids']) : [],
    );
  }
}
