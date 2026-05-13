class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.nama,
    required this.pj,
    required this.totalSiswa,
  });

  final String id;
  final String nama;
  final Map<String, String> pj;
  final int totalSiswa;
  ClassRoom copyWith({
    String? id,
    String? nama,
    Map<String, String>? pj,
    int? totalSiswa,
  }) {
    return ClassRoom(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      pj: pj ?? this.pj,
      totalSiswa: totalSiswa ?? this.totalSiswa,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'pj': pj,
      'totalSiswa': totalSiswa,
    };
  }

  factory ClassRoom.fromMap(Map<String, dynamic> map) {
    return ClassRoom(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      pj: Map<String, String>.from(map['pj'] ?? <String, String>{}),
      totalSiswa: map['totalSiswa'] ?? 0,
    );
  }
}
