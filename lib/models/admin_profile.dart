class AdminProfile {
  const AdminProfile({
    required this.username,
    required this.name,
    required this.email,
    required this.photo,
    required this.password,
  });

  final String username;
  final String name;
  final String email;
  final String photo;
  final String password;

  AdminProfile copyWith({
    String? username,
    String? name,
    String? email,
    String? photo,
    String? password,
  }) {
    return AdminProfile(
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'name': name,
      'email': email,
      'photo': photo,
      'password': password,
    };
  }

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    return AdminProfile(
      username: map['username'] ?? 'admin',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
