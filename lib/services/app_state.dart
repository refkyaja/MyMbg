import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_profile.dart';
import '../models/class_room.dart';
import '../models/menu_data.dart';
import '../models/tracking_record.dart';
import '../utils/app_constants.dart';
import '../utils/app_formatters.dart';
import 'mock_data_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _initFirestore();
    checkAndMigrateDailyData();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppView currentView = AppView.roleSelection;
  bool isAdminLoggedIn = false;

  MenuData menuData = MockDataService.initialMenuData;
  List<ClassRoom> classesData = MockDataService.initialClassesData;
  AdminProfile adminProfile = MockDataService.initialAdminProfile;
  Map<String, TrackingRecord> trackingData = <String, TrackingRecord>{};
  Map<String, Map<String, TrackingRecord>> historyData =
      MockDataService.initialHistoryData;

  int dendaRusak = 15000;
  int dendaHilang = 25000;

  String get todayLabel => AppFormatters.formatLongDate(DateTime.now());

  String get currentDayName => AppFormatters.weekdayName(DateTime.now());

  void _initFirestore() {
    // 1. Listen to Menu Data
    _db.collection('menu').doc('today').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        menuData = MenuData.fromMap(doc.data()!);
        notifyListeners();
      } else {
        // Populate default if not present in Firestore
        _db.collection('menu').doc('today').set(MockDataService.initialMenuData.toMap());
      }
    });

    // 2. Listen to Admin Profile
    _db.collection('admin').doc('profile').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        adminProfile = AdminProfile.fromMap(doc.data()!);
        notifyListeners();
      } else {
        // Populate default if not present in Firestore
        _db.collection('admin').doc('profile').set(MockDataService.initialAdminProfile.toMap());
      }
    });

    // 3. Listen to Class Rooms
    _db.collection('classes').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        classesData = snapshot.docs
            .map((doc) => ClassRoom.fromMap(doc.data()))
            .toList();
        notifyListeners();
      } else {
        // Populate defaults if collection is empty
        for (final classRoom in MockDataService.initialClassesData) {
          _db.collection('classes').doc(classRoom.id).set(classRoom.toMap());
        }
      }
    });

    // 4. Listen to Today's Tracking Data
    _db.collection('tracking').snapshots().listen((snapshot) {
      final Map<String, TrackingRecord> newTracking = {};
      for (final doc in snapshot.docs) {
        newTracking[doc.id] = TrackingRecord.fromMap(doc.data());
      }
      trackingData = newTracking;
      notifyListeners();
    });

    // 5. Listen to History Data
    _db.collection('history').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final Map<String, Map<String, TrackingRecord>> newHistory = {};
        for (final doc in snapshot.docs) {
          final Map<String, dynamic> data = doc.data();
          final Map<String, TrackingRecord> classRecords = {};
          data.forEach((classId, recordData) {
            if (recordData is Map) {
              classRecords[classId] =
                  TrackingRecord.fromMap(Map<String, dynamic>.from(recordData));
            }
          });
          newHistory[doc.id] = classRecords;
        }
        historyData = newHistory;
        notifyListeners();
      } else {
        // Populate defaults if history is empty
        MockDataService.initialHistoryData.forEach((dateLabel, classRecords) {
          final Map<String, dynamic> recordMap = {};
          classRecords.forEach((classId, record) {
            recordMap[classId] = record.toMap();
          });
          _db.collection('history').doc(dateLabel).set(recordMap);
        });
      }
    });

    // 6. Listen to Fines Settings
    _db.collection('settings').doc('fines').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data()!;
        dendaRusak = data['rusak'] ?? 15000;
        dendaHilang = data['hilang'] ?? 25000;
        notifyListeners();
      } else {
        _db.collection('settings').doc('fines').set(<String, dynamic>{
          'rusak': 15000,
          'hilang': 25000,
        });
      }
    });
  }

  String getPjHariIni(ClassRoom? classRoom) {
    if (classRoom == null) {
      return '';
    }

    return classRoom.pj[currentDayName] ?? classRoom.pj['Senin'] ?? '-';
  }

  void goToRoleSelection() {
    isAdminLoggedIn = false;
    currentView = AppView.roleSelection;
    notifyListeners();
  }

  void selectSiswaRole() {
    isAdminLoggedIn = false;
    currentView = AppView.publicPortal;
    notifyListeners();
  }

  void goToPublicPortal() {
    currentView = AppView.publicPortal;
    notifyListeners();
  }

  void goToLogin() {
    currentView = AppView.login;
    notifyListeners();
  }

  void goToAdmin() {
    currentView = AppView.admin;
    notifyListeners();
  }

  bool loginAdmin({required String username, required String password}) {
    final bool isValid =
        username == 'admin' && password == adminProfile.password;

    if (isValid) {
      isAdminLoggedIn = true;
      currentView = AppView.admin;
      notifyListeners();
    }

    return isValid;
  }

  void logoutAdmin() {
    isAdminLoggedIn = false;
    currentView = AppView.roleSelection;
    notifyListeners();
  }

  void updateMenuData(MenuData newMenuData) {
    _db.collection('menu').doc('today').set(newMenuData.toMap());
  }

  void updateAdminProfile(AdminProfile newProfile) {
    _db.collection('admin').doc('profile').set(newProfile.toMap());
  }

  void addClassRoom(ClassRoom classRoom) {
    _db.collection('classes').doc(classRoom.id).set(classRoom.toMap());
  }

  void updateClassRoom(ClassRoom updatedClassRoom) {
    _db.collection('classes').doc(updatedClassRoom.id).set(updatedClassRoom.toMap());
  }

  void deleteClassRoom(String id) {
    _db.collection('classes').doc(id).delete();
    _db.collection('tracking').doc(id).delete();
  }

  void submitPickup({required String classId, required int tidakHadir}) {
    final ClassRoom classRoom = classesData.firstWhere(
      (ClassRoom room) => room.id == classId,
    );

    final int totalDiambil = (classRoom.totalSiswa - tidakHadir).clamp(
      0,
      classRoom.totalSiswa,
    );

    final record = TrackingRecord(
      status: TrackingStatus.diambil,
      mbgDiambil: totalDiambil,
      waktuAmbil: DateTime.now(),
      denda: 0,
    );

    _db.collection('tracking').doc(classId).set(record.toMap());
  }

  void submitReturn({
    required String classId,
    required String kondisi,
    required int jumlahRusakHilang,
  }) {
    final TrackingRecord? previous = trackingData[classId];
    if (previous == null) {
      return;
    }

    final int rate = kondisi == 'Rusak' ? dendaRusak : dendaHilang;
    final int totalDenda = kondisi == 'Rusak' || kondisi == 'Hilang'
        ? jumlahRusakHilang * rate
        : 0;

    final record = previous.copyWith(
      status: TrackingStatus.selesai,
      denda: totalDenda,
      dendaLunas: false,
    );

    _db.collection('tracking').doc(classId).set(record.toMap());
  }

  void toggleDendaLunas({required String classId, required bool isLunas}) {
    final TrackingRecord? previous = trackingData[classId];
    if (previous == null) return;

    final record = previous.copyWith(dendaLunas: isLunas);
    _db.collection('tracking').doc(classId).set(record.toMap());
  }

  void toggleHistoryDendaLunas({
    required String dateLabel,
    required String classId,
    required bool isLunas,
  }) {
    final Map<String, TrackingRecord>? dateRecords = historyData[dateLabel];
    if (dateRecords == null) return;

    final TrackingRecord? previous = dateRecords[classId];
    if (previous == null) return;

    final updatedRecord = previous.copyWith(dendaLunas: isLunas);
    final Map<String, TrackingRecord> updatedRecords =
        Map<String, TrackingRecord>.from(dateRecords);
    updatedRecords[classId] = updatedRecord;

    final Map<String, dynamic> recordMap = {};
    updatedRecords.forEach((key, val) {
      recordMap[key] = val.toMap();
    });

    _db.collection('history').doc(dateLabel).set(recordMap);
  }

  Future<void> updateFines({required int rusak, required int hilang}) async {
    await _db.collection('settings').doc('fines').set(<String, dynamic>{
      'rusak': rusak,
      'hilang': hilang,
    });
  }

  Future<void> checkAndMigrateDailyData() async {
    try {
      final DocumentReference systemDoc = _db.collection('settings').doc('system_state');
      final DocumentSnapshot doc = await systemDoc.get();
      final String currentToday = todayLabel;

      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String? lastActiveDate = data['last_active_date'];

        if (lastActiveDate != null && lastActiveDate != currentToday) {
          // New day started! Migrate existing tracking data to history
          final QuerySnapshot trackingSnapshot = await _db.collection('tracking').get();

          if (trackingSnapshot.docs.isNotEmpty) {
            final Map<String, dynamic> historyRecords = {};
            for (final d in trackingSnapshot.docs) {
              historyRecords[d.id] = d.data();
            }

            // Save under last_active_date document in history
            await _db.collection('history').doc(lastActiveDate).set(historyRecords);

            // Delete tracking documents for fresh start
            final WriteBatch batch = _db.batch();
            for (final d in trackingSnapshot.docs) {
              batch.delete(d.reference);
            }
            await batch.commit();
          }

          // Update system date to today
          await systemDoc.set({'last_active_date': currentToday});
        }
      } else {
        // First run, initialize system state with today's date
        await systemDoc.set({'last_active_date': currentToday});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in daily data migration: $e');
      }
    }
  }
}
