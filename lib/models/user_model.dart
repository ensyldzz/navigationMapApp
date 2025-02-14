import 'dart:convert';

class UserModel {
  String name;
  String lastName;
  String email;
  UserModel({
    required this.name,
    required this.lastName,
    required this.email,
  });

  UserModel copyWith({
    String? name,
    String? lastName,
    String? email,
  }) {
    return UserModel(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'lastName': lastName,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserModel(name: $name, lastName: $lastName, email: $email)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.lastName == lastName && other.email == email;
  }

  @override
  int get hashCode => name.hashCode ^ lastName.hashCode ^ email.hashCode;
}
