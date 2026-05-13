import 'menu_component.dart';
import 'nutrition_info.dart';

class MenuData {
  const MenuData({
    required this.judul,
    required this.imageUrl,
    required this.gizi,
    required this.items,
  });

  final String judul;
  final String imageUrl;
  final NutritionInfo gizi;
  final List<MenuComponent> items;

  List<MenuComponent> get validItems {
    return items.where((MenuComponent item) => item.isFilled).toList();
  }

  MenuData copyWith({
    String? judul,
    String? imageUrl,
    NutritionInfo? gizi,
    List<MenuComponent>? items,
  }) {
    return MenuData(
      judul: judul ?? this.judul,
      imageUrl: imageUrl ?? this.imageUrl,
      gizi: gizi ?? this.gizi,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'judul': judul,
      'imageUrl': imageUrl,
      'gizi': gizi.toMap(),
      'items': items.map((MenuComponent item) => item.toMap()).toList(),
    };
  }

  factory MenuData.fromMap(Map<String, dynamic> map) {
    return MenuData(
      judul: map['judul'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      gizi: NutritionInfo.fromMap(Map<String, dynamic>.from(map['gizi'] ?? <String, dynamic>{})),
      items: (map['items'] as List<dynamic>?)
              ?.map((dynamic item) => MenuComponent.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          <MenuComponent>[],
    );
  }
}
