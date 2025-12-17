class CreateUserDto {
final String? name;
final String email;
final String password;

CreateUserDto({
  required this.email,
  required this.password,
  this.name
});

Map<String, dynamic> toMap(){
  return {'email': email, 'name': name};
}
  
}