class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String? phone;
  final String? token;
  final String _role;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.token,
    String role = 'USER',
  }) : _role = role;

  String get role => _role;

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    fullName: j['fullName'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    token: j['token'],
    role: j['role'] ?? 'USER',
  );
}