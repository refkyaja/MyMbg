class NutritionInfo {
  const NutritionInfo({
    required this.kalori,
    required this.protein,
    required this.karbohidrat,
    required this.lemak,
  });

  final int kalori;
  final int protein;
  final int karbohidrat;
  final int lemak;

  NutritionInfo copyWith({
    int? kalori,
    int? protein,
    int? karbohidrat,
    int? lemak,
  }) {
    return NutritionInfo(
      kalori: kalori ?? this.kalori,
      protein: protein ?? this.protein,
      karbohidrat: karbohidrat ?? this.karbohidrat,
      lemak: lemak ?? this.lemak,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'kalori': kalori,
      'protein': protein,
      'karbohidrat': karbohidrat,
      'lemak': lemak,
    };
  }

  factory NutritionInfo.fromMap(Map<String, dynamic> map) {
    return NutritionInfo(
      kalori: map['kalori'] ?? 0,
      protein: map['protein'] ?? 0,
      karbohidrat: map['karbohidrat'] ?? 0,
      lemak: map['lemak'] ?? 0,
    );
  }
}
