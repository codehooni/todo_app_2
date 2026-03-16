class User {
  final String id;
  final String name;
  final String? profileUrl;

  User({required this.id, required this.name, this.profileUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      profileUrl: json['profileUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'profileUrl': profileUrl};
  }
}
