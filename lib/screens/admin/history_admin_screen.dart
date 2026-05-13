import 'package:flutter/material.dart';

import '../../models/tracking_record.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_formatters.dart';
import '../../utils/file_saver_helper.dart';
import '../../utils/report_generator.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/status_badge.dart';

class HistoryAdminScreen extends StatefulWidget {
  const HistoryAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<HistoryAdminScreen> createState() => _HistoryAdminScreenState();
}

class _HistoryAdminScreenState extends State<HistoryAdminScreen> {
  String _filterTahun = 'all';
  String _filterBulan = 'all';
  String? _selectedDate;

  // Mapping Indonesian Month names for sorting or filtering reference
  final List<String> _indonesianMonths = <String>[
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  Widget build(BuildContext context) {
    // Extract unique years and months from history data
    final List<String> availableYears = <String>[];
    final List<String> availableMonths = <String>[];

    for (final String date in widget.appState.historyData.keys) {
      final List<String> parts = date.split(' ');
      if (parts.length >= 3) {
        final String year = parts.last;
        final String month = parts[parts.length - 2];
        if (!availableYears.contains(year)) {
          availableYears.add(year);
        }
        if (!availableMonths.contains(month)) {
          availableMonths.add(month);
        }
      }
    }

    // Sort years descending and months based on calendar order
    availableYears.sort((a, b) => b.compareTo(a));
    availableMonths.sort((a, b) {
      final int indexA = _indonesianMonths.indexOf(a);
      final int indexB = _indonesianMonths.indexOf(b);
      return indexA.compareTo(indexB);
    });

    // If a specific date is selected, render the gorgeous Date Detail Screen
    if (_selectedDate != null) {
      return _buildDetailScreen(_selectedDate!);
    }

    final List<String> filteredDates = widget.appState.historyData.keys.where((String date) {
      final List<String> parts = date.split(' ');
      if (parts.length >= 3) {
        final String year = parts.last;
        final String month = parts[parts.length - 2];

        if (_filterTahun != 'all' && year != _filterTahun) {
          return false;
        }
        if (_filterBulan != 'all' && month != _filterBulan) {
          return false;
        }
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Riwayat Monitoring',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Arsip data distribusi makanan bergizi hari-hari sebelumnya',
            style: TextStyle(color: AppColors.slate500),
          ),
          const SizedBox(height: 24),
          
          // Double filter selectors: Year and Month side-by-side
          SectionCard(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isWide = constraints.maxWidth > 640;

                final Widget yearFilter = DropdownButtonFormField<String>(
                  initialValue: _filterTahun,
                  decoration: const InputDecoration(
                    labelText: 'Filter Tahun',
                    prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                  ),
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('Semua Tahun'),
                    ),
                    ...availableYears.map(
                      (String year) => DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _filterTahun = value ?? 'all';
                    });
                  },
                );

                final Widget monthFilter = DropdownButtonFormField<String>(
                  initialValue: _filterBulan,
                  decoration: const InputDecoration(
                    labelText: 'Filter Bulan',
                    prefixIcon: Icon(Icons.date_range_rounded, size: 20),
                  ),
                  items: <DropdownMenuItem<String>>[
                    const DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('Semua Bulan'),
                    ),
                    ...availableMonths.map(
                      (String month) => DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _filterBulan = value ?? 'all';
                    });
                  },
                );

                if (isWide) {
                  return Row(
                    children: <Widget>[
                      Expanded(child: yearFilter),
                      const SizedBox(width: 16),
                      Expanded(child: monthFilter),
                    ],
                  );
                }

                return Column(
                  children: <Widget>[
                    yearFilter,
                    const SizedBox(height: 12),
                    monthFilter,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            padding: const EdgeInsets.all(20),
            child: Builder(
              builder: (BuildContext context) {
                if (_filterTahun == 'all' || _filterBulan == 'all') {
                  return Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.slate500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Ekspor Laporan Bulanan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pilih tahun dan bulan spesifik pada filter di atas untuk mengaktifkan unduhan PDF/Excel.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Count if there is data on selected month
                final List<String> monthlyRecords = widget.appState.historyData.keys.where((String date) {
                  final List<String> parts = date.split(' ');
                  if (parts.length >= 3) {
                    final String year = parts.last;
                    final String month = parts[parts.length - 2];
                    return year == _filterTahun && month == _filterBulan;
                  }
                  return false;
                }).toList();

                if (monthlyRecords.isEmpty) {
                  return Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.redSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tidak Ada Data di $_filterBulan $_filterTahun',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Arsip kosong untuk periode ini. Ekspor laporan tidak tersedia.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth > 500;

                    final Widget infoBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Ekspor Rekapitulasi - $_filterBulan $_filterTahun',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tersedia ${monthlyRecords.length} hari rekaman distribusi siap diunduh.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    );

                    final Widget actionButtons = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // PDF Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final List<int> bytes = await ReportGenerator.generatePdf(
                                month: _filterBulan,
                                year: _filterTahun,
                                historyData: widget.appState.historyData,
                              );
                              saveAndDownloadFile(
                                bytes,
                                'Laporan_MBG_${_filterBulan}_$_filterTahun.pdf',
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal ekspor PDF: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEF2F2),
                            foregroundColor: AppColors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFFEE2E2)),
                            ),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                          label: const Text(
                            'Ekspor PDF',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Excel Button
                        ElevatedButton.icon(
                          onPressed: () {
                            try {
                              final List<int> bytes = ReportGenerator.generateExcel(
                                month: _filterBulan,
                                year: _filterTahun,
                                historyData: widget.appState.historyData,
                              );
                              saveAndDownloadFile(
                                bytes,
                                'Laporan_MBG_${_filterBulan}_$_filterTahun.xlsx',
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal ekspor Excel: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFECFDF5),
                            foregroundColor: AppColors.emerald,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFD1FAE5)),
                            ),
                          ),
                          icon: const Icon(Icons.description_rounded, size: 20),
                          label: const Text(
                            'Ekspor Excel',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(child: infoBlock),
                          const SizedBox(width: 16),
                          actionButtons,
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        infoBlock,
                        const SizedBox(height: 16),
                        actionButtons,
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          if (filteredDates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: AppColors.slate50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      size: 48,
                      color: AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak Ada Data Riwayat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Silakan sesuaikan pilihan filter tahun atau bulan Anda.',
                    style: TextStyle(color: AppColors.slate500, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDates.length,
              itemBuilder: (BuildContext context, int index) {
                final String date = filteredDates[index];
                final Map<String, TrackingRecord> records =
                    widget.appState.historyData[date]!;
                final int totalDenda = records.values.fold(
                  0,
                  (int sum, TrackingRecord record) => sum + record.denda,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x03000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.blueSoft,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${records.length} kelas terdata • Total denda ${AppFormatters.formatRupiah(totalDenda)}',
                                      style: const TextStyle(
                                        color: AppColors.slate500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.slate400,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Premium Sub-Screen: History Detail Page
  Widget _buildDetailScreen(String date) {
    final Map<String, TrackingRecord> records = widget.appState.historyData[date]!;
    
    // Calculate summaries
    final int totalKelas = records.length;
    final int totalDenda = records.values.fold(0, (sum, record) => sum + record.denda);
    final int totalSelesai = records.values.where((r) => r.status.name == 'selesai').length;
    final double completionRatio = totalKelas > 0 ? (totalSelesai / totalKelas) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Back Action and Title
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate700),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  hoverColor: AppColors.slate50,
                  side: const BorderSide(color: AppColors.slate200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Detail Riwayat Monitoring',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gorgeous side-by-side Summary Cards
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isWide = constraints.maxWidth > 760;
              
              final List<Widget> cards = <Widget>[
                _buildSummaryCard(
                  title: 'Total Kelas Terdata',
                  value: '$totalKelas Kelas',
                  icon: Icons.school_rounded,
                  iconColor: AppColors.blue,
                  bgColor: AppColors.blueSoft,
                ),
                _buildSummaryCard(
                  title: 'Total Denda Hari Ini',
                  value: AppFormatters.formatRupiah(totalDenda),
                  icon: Icons.payments_rounded,
                  iconColor: totalDenda > 0 ? AppColors.red : AppColors.slate400,
                  bgColor: totalDenda > 0 ? const Color(0xFFFEF2F2) : AppColors.slate50,
                ),
                _buildSummaryCard(
                  title: 'Rasio Pengembalian',
                  value: '${(completionRatio * 100).toInt()}% Selesai',
                  icon: Icons.done_all_rounded,
                  iconColor: AppColors.emerald,
                  bgColor: AppColors.emeraldSoft,
                ),
              ];

              if (isWide) {
                return Row(
                  children: cards.map((c) => Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ))).toList(),
                );
              }

              return Column(
                children: cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Main Class Tracking Data Table
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Text(
                    'Daftar Status Pengembalian Kelas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(3.5),
                      2: FlexColumnWidth(2.5),
                      3: FlexColumnWidth(2.0),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        decoration: const BoxDecoration(
                          color: AppColors.slate900,
                        ),
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Text(
                              'Nama Kelas',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Text(
                              'Status Akhir',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Text(
                              'Total MBG Diambil',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Text(
                              'Denda',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...records.entries.map((MapEntry<String, TrackingRecord> entry) {
                        final bool selesai = entry.value.status.name == 'selesai';
                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.slate100),
                            ),
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: AppColors.slate900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: selesai
                                    ? const StatusBadge(
                                        label: 'Sudah Mengembalikan',
                                        backgroundColor: AppColors.emeraldSoft,
                                        foregroundColor: AppColors.emeraldDark,
                                      )
                                    : const StatusBadge(
                                        label: 'Belum Kembali',
                                        backgroundColor: AppColors.amberSoft,
                                        foregroundColor: Color(0xFF92400E),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              child: Text(
                                '${entry.value.mbgDiambil} Porsi',
                                style: const TextStyle(
                                  color: AppColors.slate700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              child: Text(
                                entry.value.denda > 0
                                    ? AppFormatters.formatRupiah(entry.value.denda)
                                    : '-',
                                style: TextStyle(
                                  color: entry.value.denda > 0 ? AppColors.red : AppColors.slate400,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x02000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
