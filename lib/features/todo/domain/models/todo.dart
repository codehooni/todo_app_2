class Todo {
  final String userId;
  final String id;
  final String title;
  final String? imageUrl;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;

  Todo({
    required this.userId,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.tagIds,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      tagIds: List<String>.from(json['tagIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'tagIds': tagIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
