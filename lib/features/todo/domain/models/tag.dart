import 'dart:ui';

class Tag {
  final String id;
  final String title;
  final Color color;

  Tag({required this.id, required this.title, required this.color});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      title: json['title'] as String,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.toARGB32(),
    };
  }
}
