class MenuComponent {
  const MenuComponent({
    required this.id,
    required this.kategori,
    required this.nama,
    required this.icon,
  });

  final int id;
  final String kategori;
  final String nama;
  final String icon;

  bool get isFilled => nama.trim().isNotEmpty;

  MenuComponent copyWith({
    int? id,
    String? kategori,
    String? nama,
    String? icon,
  }) {
    return MenuComponent(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      nama: nama ?? this.nama,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kategori': kategori,
      'nama': nama,
      'icon': icon,
    };
  }

  factory MenuComponent.fromMap(Map<String, dynamic> map) {
    return MenuComponent(
      id: map['id'] ?? 0,
      kategori: map['kategori'] ?? '',
      nama: map['nama'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}
