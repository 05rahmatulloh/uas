class User {
  final String email;
  final String password;
  final String role;

  User({required this.email, required this.password, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? "",
      password: json['password'] ?? "",
      role: json['role'] ?? "user",
    );
  }
}
