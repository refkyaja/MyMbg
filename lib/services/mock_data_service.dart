import '../models/admin_profile.dart';
import '../models/class_room.dart';
import '../models/menu_component.dart';
import '../models/menu_data.dart';
import '../models/nutrition_info.dart';
import '../models/tracking_record.dart';
import '../utils/app_constants.dart';

class MockDataService {
  static MenuData get initialMenuData => const MenuData(
        judul: 'Nasi Ayam Teriyaki Pedas Manis',
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&q=80&w=800',
        gizi: NutritionInfo(kalori: 650, protein: 28, karbohidrat: 85, lemak: 15),
    items: <MenuComponent>[
      MenuComponent(
        id: 1,
        kategori: 'Karbohidrat',
        nama: 'Nasi Putih Hangat',
        icon: '🍚',
      ),
      MenuComponent(
        id: 2,
        kategori: 'Protein Hewani',
        nama: 'Ayam Teriyaki Pedas Manis',
        icon: '🍗',
      ),
      MenuComponent(
        id: 3,
        kategori: 'Protein Nabati',
        nama: 'Tempe Mendoan',
        icon: '🧆',
      ),
      MenuComponent(
        id: 4,
        kategori: 'Sayuran',
        nama: 'Tumis Brokoli & Wortel',
        icon: '🥦',
      ),
      MenuComponent(
        id: 5,
        kategori: 'Buah',
        nama: 'Pisang',
        icon: '🍌',
      ),
    ],
  );

  static List<ClassRoom> get initialClassesData => const <ClassRoom>[
    ClassRoom(
      id: 'XI RPL 1',
      nama: 'XI RPL 1',
      totalSiswa: 36,
      pj: <String, String>{
        'Senin': 'Rina Marlina, S.Pd',
        'Selasa': 'Ahmad Fauzi, S.Kom',
        'Rabu': 'Budi Santoso, M.T',
        'Kamis': 'Siti Aminah, S.T',
        'Jumat': 'Rina Marlina, S.Pd',
      },
    ),
    ClassRoom(
      id: 'XI RPL 2',
      nama: 'XI RPL 2',
      totalSiswa: 35,
      pj: <String, String>{
        'Senin': 'Ahmad Fauzi, S.Kom',
        'Selasa': 'Rina Marlina, S.Pd',
        'Rabu': 'Siti Aminah, S.T',
        'Kamis': 'Budi Santoso, M.T',
        'Jumat': 'Ahmad Fauzi, S.Kom',
      },
    ),
    ClassRoom(
      id: 'XI TKJ 1',
      nama: 'XI TKJ 1',
      totalSiswa: 34,
      pj: <String, String>{
        'Senin': 'Budi Santoso, M.T',
        'Selasa': 'Siti Aminah, S.T',
        'Rabu': 'Rina Marlina, S.Pd',
        'Kamis': 'Ahmad Fauzi, S.Kom',
        'Jumat': 'Budi Santoso, M.T',
      },
    ),
    ClassRoom(
      id: 'XI TKJ 2',
      nama: 'XI TKJ 2',
      totalSiswa: 36,
      pj: <String, String>{
        'Senin': 'Siti Aminah, S.T',
        'Selasa': 'Budi Santoso, M.T',
        'Rabu': 'Ahmad Fauzi, S.Kom',
        'Kamis': 'Rina Marlina, S.Pd',
        'Jumat': 'Siti Aminah, S.T',
      },
    ),
  ];

  static AdminProfile get initialAdminProfile => const AdminProfile(
    username: 'admin',
    name: 'Administrator Utama',
    email: 'admin@mymbg.com',
    photo:
        'https://ui-avatars.com/api/?name=Admin+Utama&background=10b981&color=fff',
    password: 'admin',
  );

  static Map<String, Map<String, TrackingRecord>> get initialHistoryData =>
      <String, Map<String, TrackingRecord>>{
        'Senin, 27 April 2026': <String, TrackingRecord>{
          'XI RPL 1': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 35,
            denda: 0,
          ),
          'XI RPL 2': const TrackingRecord(
            status: TrackingStatus.diambil,
            mbgDiambil: 34,
            denda: 0,
          ),
          'XI TKJ 1': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 34,
            denda: 25000,
          ),
        },
        'Jumat, 24 April 2026': <String, TrackingRecord>{
          'XI RPL 1': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 36,
            denda: 0,
          ),
          'XI RPL 2': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 35,
            denda: 0,
          ),
          'XI TKJ 1': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 34,
            denda: 0,
          ),
          'XI TKJ 2': const TrackingRecord(
            status: TrackingStatus.selesai,
            mbgDiambil: 36,
            denda: 0,
          ),
        },
      };
}
