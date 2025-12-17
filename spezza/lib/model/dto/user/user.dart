class SpezzaUser {
  final int id;
  final String? name;
  final String email;
  final String password;

  SpezzaUser({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  factory SpezzaUser.fromMap(Map<String, dynamic> map) {
    return SpezzaUser(
      id: map['id'] as int,
      name: map['name'] as String?,
      email: map['email'],
      password: map['password'],
    );
  }
}
