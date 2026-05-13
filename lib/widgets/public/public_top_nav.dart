import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/admin_profile.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class PublicTopNav extends StatelessWidget {
  const PublicTopNav({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.isAdminLoggedIn,
    required this.profile,
    required this.onLoginTap,
    required this.onDashboardTap,
    required this.onLogoutTap,
    required this.onBrandTap,
  });

  final PublicTab activeTab;
  final ValueChanged<PublicTab> onTabChanged;
  final bool isAdminLoggedIn;
  final AdminProfile profile;
  final VoidCallback onLoginTap;
  final VoidCallback onDashboardTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onBrandTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors
          .emeraldDark, // Use deeper green (0xFF059669) for a premium look
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Brand Logo
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onBrandTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                size: 24,
                                color: Color(0xFF009661), // Green color matching the background
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'MyMbg',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Navigation & Actions
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        _NavChip(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          isActive: activeTab == PublicTab.home,
                          onTap: () => onTabChanged(PublicTab.home),
                        ),
                        _NavChip(
                          icon: Icons.restaurant_outlined,
                          label: 'Ambil',
                          isActive: activeTab == PublicTab.pengambilan,
                          onTap: () => onTabChanged(PublicTab.pengambilan),
                        ),
                        _NavChip(
                          icon: Icons.history,
                          label: 'Kembali',
                          isActive: activeTab == PublicTab.pengembalian,
                          onTap: () => onTabChanged(PublicTab.pengembalian),
                        ),

                        // Separator and Profile for Logged In Admin
                        if (isAdminLoggedIn) ...<Widget>[
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0x40FFFFFF),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          PopupMenuButton<String>(
                            offset: const Offset(0, 50),
                            onSelected: (String value) {
                              if (value == 'dashboard') {
                                onDashboardTap();
                              } else {
                                onLogoutTap();
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    enabled: false,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          profile.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.slate900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Administrator',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem<String>(
                                    value: 'dashboard',
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.dashboard_rounded),
                                        SizedBox(width: 12),
                                        Text('Dashboard Admin'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'logout',
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Logout'),
                                      ],
                                    ),
                                  ),
                                ],
                            child: _ProfileAvatar(
                              imageUrl: profile.photo,
                              name: profile.name,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavChip extends StatefulWidget {
  const _NavChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavChip> createState() => _NavChipState();
}

class _NavChipState extends State<_NavChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlight = widget.isActive || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          0.0,
          widget.isActive ? -1.0 : (_isHovered ? -3.0 : 0.0),
          0.0,
        ) * Matrix4.diagonal3Values(highlight ? 1.03 : 1.0, highlight ? 1.03 : 1.0, 1.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFF006D44)
                  : (_isHovered ? const Color(0x20FFFFFF) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              boxShadow: widget.isActive
                  ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0x26000000),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isHovered ? 0.04 : 0.0,
                  child: Icon(widget.icon, size: 20, color: AppColors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.name});

  final String imageUrl;
  final String name;

  Widget _buildAvatarWidget(String initials) {
    if (imageUrl.isEmpty) {
      return _buildInitialsAvatar(initials);
    }

    try {
      if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
        final String base64Str = imageUrl.split('base64,')[1];
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
            return _buildInitialsAvatar(initials);
          },
        );
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
            return _buildInitialsAvatar(initials);
          },
        );
      } else {
        if (kIsWeb) {
          return _buildInitialsAvatar(initials);
        } else {
          return Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
              return _buildInitialsAvatar(initials);
            },
          );
        }
      }
    } catch (e) {
      return _buildInitialsAvatar(initials);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _getInitials(name);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x80FFFFFF), width: 1.5),
      ),
      child: ClipOval(
        child: _buildAvatarWidget(initials),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: const Color(
        0xFF008955,
      ), // Exact color from the initials badge in the image
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'AU';
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}

class AppleOutlineIcon extends StatelessWidget {
  const AppleOutlineIcon({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AppleOutlinePainter(color: color),
    );
  }
}

class _AppleOutlinePainter extends CustomPainter {
  const _AppleOutlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Draw Apple body
    final Path path = Path();
    path.moveTo(w * 0.5, h * 0.32); // Top dip

    // Top-right lobe
    path.cubicTo(w * 0.64, h * 0.20, w * 0.88, h * 0.28, w * 0.86, h * 0.54);
    // Bottom-right lobe
    path.cubicTo(w * 0.84, h * 0.72, w * 0.64, h * 0.86, w * 0.5, h * 0.83);
    // Bottom-left lobe
    path.cubicTo(w * 0.36, h * 0.86, w * 0.16, h * 0.72, w * 0.14, h * 0.54);
    // Top-left lobe
    path.cubicTo(w * 0.12, h * 0.28, w * 0.36, h * 0.20, w * 0.5, h * 0.32);

    canvas.drawPath(path, paint);

    // Draw Stem
    final Path stemPath = Path();
    stemPath.moveTo(w * 0.5, h * 0.30);
    stemPath.quadraticBezierTo(w * 0.46, h * 0.18, w * 0.44, h * 0.12);
    canvas.drawPath(stemPath, paint);

    // Draw Leaf (on the right)
    final Path leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.22);
    leafPath.quadraticBezierTo(w * 0.62, h * 0.10, w * 0.72, h * 0.12);
    leafPath.quadraticBezierTo(w * 0.60, h * 0.24, w * 0.5, h * 0.22);

    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
