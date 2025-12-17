class SpezzaUser {
  final int id;
  final String? name;
  final String email;

  SpezzaUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory SpezzaUser.fromMap(Map<String, dynamic> map) {
    return SpezzaUser(
      id: map['id'] as int,
      name: map['name'] as String?,
      email: map['email'],
    );
  }
}
