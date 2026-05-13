import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/menu_component.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/public/menu_item_card.dart';
import '../../widgets/public/nutrition_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final List<MenuComponent> validItems = appState.menuData.validItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.emerald, AppColors.teal],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1F10B981),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth > 760;
                    final Widget imageBox = Container(
                      height: isWide ? 220 : 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildMenuImageWidget(appState.menuData.imageUrl),
                    );

                    return isWide
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Text(
                                      'Menu MBG Hari Ini',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      appState.menuData.judul,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.calendar_month_rounded,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          appState.todayLabel,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              SizedBox(width: 300, child: imageBox),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Menu MBG Hari Ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appState.menuData.judul,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      appState.todayLabel,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              imageBox,
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isWide = constraints.maxWidth > 880;
                  final Widget nutritionSection = SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Row(
                          children: <Widget>[
                            Icon(
                              Icons.monitor_heart_rounded,
                              color: AppColors.emerald,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Total Gizi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        NutritionBar(
                          label: 'Kalori',
                          valueLabel: '${appState.menuData.gizi.kalori} kcal',
                          color: AppColors.amber,
                          progress: appState.menuData.gizi.kalori > 0
                              ? (appState.menuData.gizi.kalori / 1000.0).clamp(0.0, 1.0)
                              : 0.0,
                        ),
                        const SizedBox(height: 18),
                        NutritionBar(
                          label: 'Protein',
                          valueLabel: '${appState.menuData.gizi.protein} g',
                          color: AppColors.emerald,
                          progress: appState.menuData.gizi.protein > 0
                              ? (appState.menuData.gizi.protein / 40.0).clamp(0.0, 1.0)
                              : 0.0,
                        ),
                        const SizedBox(height: 18),
                        NutritionBar(
                          label: 'Karbohidrat',
                          valueLabel: '${appState.menuData.gizi.karbohidrat} g',
                          color: AppColors.blue,
                          progress: appState.menuData.gizi.karbohidrat > 0
                              ? (appState.menuData.gizi.karbohidrat / 150.0).clamp(0.0, 1.0)
                              : 0.0,
                        ),
                        const SizedBox(height: 18),
                        NutritionBar(
                          label: 'Lemak',
                          valueLabel: '${appState.menuData.gizi.lemak} g',
                          color: AppColors.red,
                          progress: appState.menuData.gizi.lemak > 0
                              ? (appState.menuData.gizi.lemak / 30.0).clamp(0.0, 1.0)
                              : 0.0,
                        ),
                      ],
                    ),
                  );

                  final Widget compositionSection = SectionCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Komposisi Menu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: LayoutBuilder(
                            builder:
                                (
                                  BuildContext context,
                                  BoxConstraints itemConstraints,
                                ) {
                                  final int crossAxisCount =
                                      validItems.length > 4
                                      ? (itemConstraints.maxWidth > 720 ? 3 : 2)
                                      : (itemConstraints.maxWidth > 720
                                            ? 2
                                            : 1);

                                  if (validItems.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Tidak ada rincian menu yang tersedia hari ini.',
                                          style: TextStyle(
                                            color: AppColors.slate500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return GridView.builder(
                                    itemCount: validItems.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 92,
                                        ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          return MenuItemCard(
                                            item: validItems[index],
                                          );
                                        },
                                  );
                                },
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 300, child: nutritionSection),
                        const SizedBox(width: 16),
                        Expanded(child: compositionSection),
                      ],
                    );
                  }

                  return Column(
                    children: <Widget>[
                      nutritionSection,
                      const SizedBox(height: 16),
                      compositionSection,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuImageWidget(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        color: AppColors.slate100,
        alignment: Alignment.center,
        child: const Text(
          'Gambar tidak tersedia',
          style: TextStyle(color: AppColors.slate500),
        ),
      );
    }

    try {
      if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
        final String base64Str = imageUrl.split('base64,')[1];
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.slate100,
            alignment: Alignment.center,
            child: const Text(
              'Gagal memuat gambar',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
        );
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.slate100,
            alignment: Alignment.center,
            child: const Text(
              'Gagal memuat gambar',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
        );
      } else {
        if (kIsWeb) {
          return Container(
            color: AppColors.slate100,
            alignment: Alignment.center,
            child: const Text(
              'Gambar tidak tersedia',
              style: TextStyle(color: AppColors.slate500),
            ),
          );
        } else {
          return Image.file(
            io.File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
              color: AppColors.slate100,
              alignment: Alignment.center,
              child: const Text(
                'Gagal memuat gambar',
                style: TextStyle(color: AppColors.slate500),
              ),
            ),
          );
        }
      }
    } catch (e) {
      return Container(
        color: AppColors.slate100,
        alignment: Alignment.center,
        child: const Text(
          'Gagal memuat gambar',
          style: TextStyle(color: AppColors.slate500),
        ),
      );
    }
  }
}
