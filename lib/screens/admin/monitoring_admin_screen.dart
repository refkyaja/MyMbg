import 'package:flutter/material.dart';

import '../../models/class_room.dart';
import '../../models/tracking_record.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/status_badge.dart';

class MonitoringAdminScreen extends StatefulWidget {
  const MonitoringAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<MonitoringAdminScreen> createState() => _MonitoringAdminScreenState();
}

class _MonitoringAdminScreenState extends State<MonitoringAdminScreen> {
  String _filterStatus = 'all';
  String _filterKelas = '';

  @override
  Widget build(BuildContext context) {
    final List<ClassRoom> filteredClasses = widget.appState.classesData.where((
      ClassRoom room,
    ) {
      final TrackingStatus status =
          widget.appState.trackingData[room.id]?.status ?? TrackingStatus.belum;

      if (_filterKelas.isNotEmpty &&
          !room.nama.toLowerCase().contains(_filterKelas.toLowerCase())) {
        return false;
      }

      if (_filterStatus == 'belum_ambil' && status != TrackingStatus.belum) {
        return false;
      }
      if (_filterStatus == 'sudah_ambil' && status == TrackingStatus.belum) {
        return false;
      }
      if (_filterStatus == 'belum_kembali' && status != TrackingStatus.diambil) {
        return false;
      }
      if (_filterStatus == 'sudah_kembali' && status != TrackingStatus.selesai) {
        return false;
      }

      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Monitoring & Laporan Hari Ini',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pantau detail status pengambilan dan pengembalian',
            style: TextStyle(color: AppColors.slate500),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isWide = constraints.maxWidth > 720;

                const List<String> validValues = <String>[
                  'all',
                  'belum_ambil',
                  'sudah_ambil',
                  'belum_kembali',
                  'sudah_kembali',
                ];
                final String currentFilter = validValues.contains(_filterStatus)
                    ? _filterStatus
                    : 'all';

                final Widget statusFilter = DropdownButtonFormField<String>(
                  initialValue: currentFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter Status Distribusi',
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tampilkan Semua'),
                    ),
                    DropdownMenuItem(
                      value: 'belum_ambil',
                      child: Text('Belum Mengambil'),
                    ),
                    DropdownMenuItem(
                      value: 'sudah_ambil',
                      child: Text('Sudah Mengambil'),
                    ),
                    DropdownMenuItem(
                      value: 'belum_kembali',
                      child: Text('Belum Mengembalikan'),
                    ),
                    DropdownMenuItem(
                      value: 'sudah_kembali',
                      child: Text('Sudah Mengembalikan'),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _filterStatus = value ?? 'all';
                    });
                  },
                );

                final Widget classFilter = TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Pencarian Kelas',
                    hintText: 'Ketik nama kelas...',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _filterKelas = value;
                    });
                  },
                );

                if (isWide) {
                  return Row(
                    children: <Widget>[
                      Expanded(child: statusFilter),
                      const SizedBox(width: 12),
                      Expanded(child: classFilter),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    statusFilter,
                    const SizedBox(height: 12),
                    classFilter,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          filteredClasses.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: AppColors.slate50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 52,
                          color: AppColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Data Tidak Ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.slate800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Silakan sesuaikan filter status atau kata kunci kelas pencarian Anda.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.slate500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SectionCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.slate900,
                      ),
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      dataRowMinHeight: 64.0,
                      dataRowMaxHeight: 76.0,
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Nama Kelas')),
                        DataColumn(label: Text('Penanggung Jawab')),
                        DataColumn(label: Text('Status Pengambilan')),
                        DataColumn(label: Text('Status Pengembalian')),
                        DataColumn(label: Text('Jumlah MBG')),
                        DataColumn(label: Center(child: Text('Denda'))),
                      ],
                      rows: filteredClasses.map((ClassRoom room) {
                        final TrackingRecord? track =
                            widget.appState.trackingData[room.id];
                        final TrackingStatus status =
                            track?.status ?? TrackingStatus.belum;
                        final bool sudahAmbil =
                            status == TrackingStatus.diambil ||
                            status == TrackingStatus.selesai;
                        final bool sudahKembali =
                            status == TrackingStatus.selesai;

                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Text(
                                room.nama,
                                style: const TextStyle(
                                  color: AppColors.emeraldDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            DataCell(Text(widget.appState.getPjHariIni(room))),
                            DataCell(
                              Center(
                                child: sudahAmbil
                                    ? const StatusBadge(
                                        label: 'Sudah Mengambil',
                                        backgroundColor: AppColors.emeraldSoft,
                                        foregroundColor: AppColors.emeraldDark,
                                      )
                                    : const StatusBadge(
                                        label: 'Belum Mengambil',
                                        backgroundColor: AppColors.slate100,
                                        foregroundColor: AppColors.slate600,
                                      ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: sudahKembali
                                    ? const StatusBadge(
                                        label: 'Sudah Mengembalikan',
                                        backgroundColor: AppColors.emeraldSoft,
                                        foregroundColor: AppColors.emeraldDark,
                                      )
                                    : const StatusBadge(
                                        label: 'Belum Mengembalikan',
                                        backgroundColor: AppColors.amberSoft,
                                        foregroundColor: Color(0xFF92400E),
                                      ),
                              ),
                            ),
                            DataCell(
                              Text(
                                sudahAmbil
                                    ? '${track?.mbgDiambil ?? 0} / ${room.totalSiswa}'
                                    : '-',
                              ),
                            ),
                            DataCell(
                              Center(
                                child: track != null && track.denda > 0
                                    ? Tooltip(
                                        message:
                                            'Klik untuk ubah status pembayaran',
                                        child: InkWell(
                                          onTap: () => _showDendaStatusDialog(
                                            context,
                                            room.id,
                                            track,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: track.dendaLunas
                                                    ? AppColors.emerald
                                                        .withOpacity(0.25)
                                                    : AppColors.red
                                                        .withOpacity(0.25),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: track.dendaLunas
                                                  ? AppColors.emeraldSoft
                                                      .withOpacity(0.2)
                                                  : AppColors.redSoft
                                                      .withOpacity(0.2),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  AppFormatters.formatRupiah(
                                                      track.denda),
                                                  style: TextStyle(
                                                    color: track.dendaLunas
                                                        ? AppColors.emeraldDark
                                                        : AppColors.red,
                                                    fontWeight: FontWeight.w700,
                                                    decoration: track.dendaLunas
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                StatusBadge(
                                                  label: track.dendaLunas
                                                      ? 'Lunas'
                                                      : 'Belum Lunas',
                                                  backgroundColor: track
                                                          .dendaLunas
                                                      ? AppColors.emeraldSoft
                                                      : AppColors.redSoft,
                                                  foregroundColor: track
                                                          .dendaLunas
                                                      ? AppColors.emeraldDark
                                                      : AppColors.red,
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(
                                                  Icons.edit_rounded,
                                                  size: 14,
                                                  color: track.dendaLunas
                                                      ? AppColors.emeraldDark
                                                          .withOpacity(0.7)
                                                      : AppColors.red
                                                          .withOpacity(0.7),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        '-',
                                        style: TextStyle(
                                            color: AppColors.slate400),
                                      ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showDendaStatusDialog(
    BuildContext context,
    String classId,
    TrackingRecord track,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status Pembayaran Denda - $classId'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Denda sebesar ${AppFormatters.formatRupiah(track.denda)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ubah status pembayaran denda kelas ini:',
                style: TextStyle(color: isDark ? AppColors.slate300 : AppColors.slate600),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.slate500,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState
                    .toggleDendaLunas(classId: classId, isLunas: false);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Text(
                'Belum Lunas',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState
                    .toggleDendaLunas(classId: classId, isLunas: true);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Text(
                'Lunas',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}
