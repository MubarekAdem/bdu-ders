class User {
  final String id;
  final String? name;
  final String email;
  final String role;

  User({required this.id, this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      'email': email,
      'role': role,
    };
  }
}
