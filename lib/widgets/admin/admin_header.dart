import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/admin_profile.dart';
import '../../utils/app_colors.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.profile,
    required this.onProfileTap,
    required this.onBackToPortal,
    this.showMenuButton = false,
    this.onMenuTap,
    this.isSidebarCollapsed = false,
    this.onToggleSidebar,
    this.isDark = false,
    required this.onToggleDarkMode,
  });

  final AdminProfile profile;
  final VoidCallback onProfileTap;
  final VoidCallback onBackToPortal;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;
  final bool isSidebarCollapsed;
  final VoidCallback? onToggleSidebar;
  final bool isDark;
  final VoidCallback onToggleDarkMode;

  Widget _buildAvatarWidget(String initial) {
    if (profile.photo.isEmpty) {
      return Container(
        color: AppColors.emerald,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    try {
      if (profile.photo.startsWith('data:image/') && profile.photo.contains('base64,')) {
        final String base64Str = profile.photo.split('base64,')[1];
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
      } else if (profile.photo.startsWith('http')) {
        return Image.network(
          profile.photo,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        );
      } else {
        if (kIsWeb) {
          return Container(
            color: AppColors.emerald,
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        } else {
          return Image.file(
            io.File(profile.photo),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
              color: AppColors.emerald,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      return Container(
        color: AppColors.emerald,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.sizeOf(context).width > 720;
    final String initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.slate700 : AppColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          if (showMenuButton)
            IconButton(
              onPressed: onMenuTap,
              icon: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : AppColors.slate700,
              ),
            ),
          if (onToggleSidebar != null && !showMenuButton)
            IconButton(
              onPressed: onToggleSidebar,
              tooltip: isSidebarCollapsed ? 'Buka Sidebar' : 'Ciutkan Sidebar',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSidebarCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                  key: ValueKey<bool>(isSidebarCollapsed),
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (isWide)
            Expanded(
              child: Text(
                'Panel Administrator MyMbg',
                style: TextStyle(
                  color: isDark ? AppColors.slate400 : AppColors.slate500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Spacer(),
          // Dark Mode Toggle
          Tooltip(
            message: isDark ? 'Mode Terang' : 'Mode Gelap',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleDarkMode,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x33F59E0B) : const Color(0x1A334155),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      key: ValueKey<bool>(isDark),
                      color: isDark ? AppColors.amber : AppColors.slate600,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onBackToPortal,
            icon: Icon(
              Icons.home_rounded,
              color: isDark ? AppColors.emerald : null,
            ),
            label: Text(
              isWide ? 'Home Portal' : 'Home',
              style: TextStyle(
                color: isDark ? AppColors.emerald : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: ClipOval(
                      child: _buildAvatarWidget(initial),
                    ),
                  ),
                  if (isWide) ...<Widget>[
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          profile.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.slate900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Administrator',
                          style: TextStyle(
                            color: AppColors.emerald,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
