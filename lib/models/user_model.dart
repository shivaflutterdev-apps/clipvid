class UserModel {
  final String id;
  final String email;
  final String name;
  final String plan;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.plan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      plan: json['plan'] ?? 'FREE',
    );
  }
}
