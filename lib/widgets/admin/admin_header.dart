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
  });

  final AdminProfile profile;
  final VoidCallback onProfileTap;
  final VoidCallback onBackToPortal;
  final bool showMenuButton;
  final VoidCallback? onMenuTap;

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

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200)),
      ),
      child: Row(
        children: <Widget>[
          if (showMenuButton)
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu_rounded),
            ),
          if (isWide)
            const Expanded(
              child: Text(
                'Panel Administrator Sistem Pendataan MBG',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Spacer(),
          TextButton.icon(
            onPressed: onBackToPortal,
            icon: const Icon(Icons.home_rounded),
            label: Text(isWide ? 'Home Portal' : 'Home'),
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
                          style: const TextStyle(
                            color: AppColors.slate900,
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
