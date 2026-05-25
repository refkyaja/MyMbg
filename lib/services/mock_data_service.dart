import '../models/admin_profile.dart';
import '../models/class_room.dart';
import '../models/menu_component.dart';
import '../models/menu_data.dart';
import '../models/nutrition_info.dart';
import '../models/tracking_record.dart';

class MockDataService {
  static MenuData get initialMenuData => const MenuData(
        judul: '',
        imageUrl: '',
        gizi: NutritionInfo(kalori: 0, protein: 0, karbohidrat: 0, lemak: 0),
        items: <MenuComponent>[],
      );

  static List<ClassRoom> get initialClassesData => const <ClassRoom>[];

  static AdminProfile get initialAdminProfile => const AdminProfile(
        username: 'admin',
        name: 'Administrator',
        email: '',
        photo: '',
        password: 'admin',
      );

  static Map<String, Map<String, TrackingRecord>> get initialHistoryData =>
      <String, Map<String, TrackingRecord>>{};
}
