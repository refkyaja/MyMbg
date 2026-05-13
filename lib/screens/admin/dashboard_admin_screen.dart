import 'package:flutter/material.dart';

import '../../models/tracking_record.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../widgets/admin/admin_stat_card.dart';
import '../../widgets/common/section_card.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final int totalKelas = appState.classesData.length;
    final int sudahDiambil = appState.classesData.where((room) {
      final TrackingStatus status =
          appState.trackingData[room.id]?.status ?? TrackingStatus.belum;
      return status == TrackingStatus.diambil ||
          status == TrackingStatus.selesai;
    }).length;
    final int sudahKembali = appState.classesData.where((room) {
      final TrackingStatus status =
          appState.trackingData[room.id]?.status ?? TrackingStatus.belum;
      return status == TrackingStatus.selesai;
    }).length;
    final int totalDenda = appState.trackingData.values.fold(
      0,
      (int sum, TrackingRecord record) => sum + record.denda,
    );
    final int dendaBelumLunas = appState.trackingData.values
        .where((record) => !record.dendaLunas)
        .fold(0, (int sum, TrackingRecord record) => sum + record.denda);
    final List<MapEntry<String, TrackingRecord>> recentActivities = appState
        .trackingData
        .entries
        .toList()
        .reversed
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Dashboard Utama',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ringkasan operasional MBG hari ini (${appState.todayLabel})',
            style: const TextStyle(color: AppColors.slate500),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth > 800
                  ? 4
                  : constraints.maxWidth > 500
                  ? 2
                  : 1;
              final double childAspectRatio = columns == 4
                  ? (constraints.maxWidth > 1100 ? 2.4 : 1.8)
                  : columns == 2
                      ? 2.1
                      : 3.2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
                children: <Widget>[
                  AdminStatCard(
                    icon: Icons.groups_rounded,
                    iconBackground: AppColors.blueSoft,
                    iconColor: AppColors.blue,
                    label: 'Total Kelas',
                    value: '$totalKelas',
                  ),
                  AdminStatCard(
                    icon: Icons.inventory_2_rounded,
                    iconBackground: AppColors.amberSoft,
                    iconColor: AppColors.amber,
                    label: 'Sudah Diambil',
                    value: '$sudahDiambil',
                    trailing: '/ $totalKelas',
                  ),
                  AdminStatCard(
                    icon: Icons.assignment_return_rounded,
                    iconBackground: AppColors.emeraldSoft,
                    iconColor: AppColors.emerald,
                    label: 'Sudah Kembali',
                    value: '$sudahKembali',
                    trailing: '/ $totalKelas',
                  ),
                  AdminStatCard(
                    icon: Icons.warning_amber_rounded,
                    iconBackground: AppColors.redSoft,
                    iconColor: AppColors.red,
                    label: 'Akumulasi Denda',
                    value: AppFormatters.formatRupiah(totalDenda),
                    trailing: dendaBelumLunas > 0
                        ? '(${AppFormatters.formatRupiah(dendaBelumLunas)} Belum Lunas)'
                        : null,
                    trailingFontSize: 16,
                    trailingColor: AppColors.red,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(Icons.calendar_month_rounded, color: AppColors.blue),
                    SizedBox(width: 10),
                    Text(
                      'Aktivitas Terakhir Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (recentActivities.isEmpty)
                  const SizedBox(
                    height: 180,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 44,
                            color: AppColors.slate400,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Belum ada aktivitas hari ini.',
                            style: TextStyle(color: AppColors.slate500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: recentActivities.map((entry) {
                      final bool selesai =
                          entry.value.status == TrackingStatus.selesai;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selesai
                                    ? AppColors.emeraldSoft
                                    : AppColors.amberSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                selesai
                                    ? Icons.assignment_return_rounded
                                    : Icons.restaurant_rounded,
                                color: selesai
                                    ? AppColors.emerald
                                    : AppColors.amber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(
                                      style: const TextStyle(
                                        color: AppColors.slate700,
                                      ),
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.slate900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: selesai
                                              ? ' telah mengembalikan kotak makan.'
                                              : ' mengambil ${entry.value.mbgDiambil} porsi MBG.',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.value.waktuAmbil == null
                                        ? '-'
                                        : AppFormatters.formatShortTime(
                                            entry.value.waktuAmbil!,
                                          ),
                                    style: const TextStyle(
                                      color: AppColors.slate500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
