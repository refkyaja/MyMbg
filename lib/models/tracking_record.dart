import '../utils/app_constants.dart';

class TrackingRecord {
  const TrackingRecord({
    required this.status,
    required this.mbgDiambil,
    this.waktuAmbil,
    this.denda = 0,
    this.dendaLunas = false,
  });

  final TrackingStatus status;
  final int mbgDiambil;
  final DateTime? waktuAmbil;
  final int denda;
  final bool dendaLunas;

  TrackingRecord copyWith({
    TrackingStatus? status,
    int? mbgDiambil,
    DateTime? waktuAmbil,
    int? denda,
    bool? dendaLunas,
  }) {
    return TrackingRecord(
      status: status ?? this.status,
      mbgDiambil: mbgDiambil ?? this.mbgDiambil,
      waktuAmbil: waktuAmbil ?? this.waktuAmbil,
      denda: denda ?? this.denda,
      dendaLunas: dendaLunas ?? this.dendaLunas,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.name,
      'mbgDiambil': mbgDiambil,
      'waktuAmbil': waktuAmbil?.toIso8601String(),
      'denda': denda,
      'dendaLunas': dendaLunas,
    };
  }

  factory TrackingRecord.fromMap(Map<String, dynamic> map) {
    final String statusStr = map['status'] ?? 'belum';
    final TrackingStatus status = TrackingStatus.values.firstWhere(
      (TrackingStatus e) => e.name == statusStr,
      orElse: () => TrackingStatus.belum,
    );
    final String? waktuAmbilStr = map['waktuAmbil'];
    final DateTime? waktuAmbil =
        waktuAmbilStr != null ? DateTime.tryParse(waktuAmbilStr) : null;
    return TrackingRecord(
      status: status,
      mbgDiambil: map['mbgDiambil'] ?? 0,
      waktuAmbil: waktuAmbil,
      denda: map['denda'] ?? 0,
      dendaLunas: map['dendaLunas'] == true,
    );
  }
}
