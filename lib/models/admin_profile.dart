class AdminProfile {
  const AdminProfile({
    required this.name,
    required this.email,
    required this.photo,
    required this.password,
  });

  final String name;
  final String email;
  final String photo;
  final String password;

  AdminProfile copyWith({
    String? name,
    String? email,
    String? photo,
    String? password,
  }) {
    return AdminProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'photo': photo,
      'password': password,
    };
  }

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    return AdminProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
