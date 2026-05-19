import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/section_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF022C22), // Deep forest green
              Color(0xFF064E3B), // Dark emerald green
              Color(0xFF0F172A), // Dark slate grey
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Logo and Title
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 52,
                        color: AppColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Selamat Datang di MyMbg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Silakan pilih peran Anda untuk masuk ke sistem pendataan Makan Bergizi Gratis (MBG)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Role Cards Container (Row on desktop, Column on mobile)
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final bool isWide = constraints.maxWidth > 600;
                        if (isWide) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: _RoleCard(
                                    icon: Icons.school_rounded,
                                    iconColor: AppColors.emerald,
                                    iconBackground: const Color(0xFFD1FAE5),
                                    title: 'Siswa / Kelas',
                                    description:
                                        'Masuk untuk melihat menu harian, melakukan pengambilan, serta mengembalikan kotak makan kelas Anda.',
                                    onTap: appState.selectSiswaRole,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _RoleCard(
                                    icon: Icons.admin_panel_settings_rounded,
                                    iconColor: AppColors.blue,
                                    iconBackground: const Color(0xFFDBEAFE),
                                    title: 'Administrator',
                                    description:
                                        'Masuk ke dashboard pengelola untuk mengelola menu harian, data kelas, serta memonitor status denda & gizi.',
                                    onTap: appState.goToLogin,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Column(
                            children: <Widget>[
                              _RoleCard(
                                icon: Icons.school_rounded,
                                iconColor: AppColors.emerald,
                                iconBackground: const Color(0xFFD1FAE5),
                                title: 'Siswa / Kelas',
                                description:
                                    'Masuk untuk melihat menu harian, melakukan pengambilan, serta mengembalikan kotak makan kelas Anda.',
                                onTap: appState.selectSiswaRole,
                              ),
                              const SizedBox(height: 24),
                              _RoleCard(
                                icon: Icons.admin_panel_settings_rounded,
                                iconColor: AppColors.blue,
                                iconBackground: const Color(0xFFDBEAFE),
                                title: 'Administrator',
                                description:
                                    'Masuk ke dashboard pengelola untuk mengelola menu harian, data kelas, serta memonitor status denda & gizi.',
                                onTap: appState.goToLogin,
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 48),
                    // Subtle Footer
                    const Text(
                      'Aplikasi Pendataan MyMbg • Dikembangkan khusus Laptop & Windows',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        child: SectionCard(
          padding: const EdgeInsets.all(28),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 36,
                    color: widget.iconColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: <Widget>[
                    Text(
                      'Masuk Sekarang',
                      style: TextStyle(
                        color: widget.iconColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: widget.iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
