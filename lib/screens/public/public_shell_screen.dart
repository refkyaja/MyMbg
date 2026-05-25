import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/public/public_top_nav.dart';
import 'home_screen.dart';
import 'pickup_screen.dart';
import 'return_screen.dart';

class PublicShellScreen extends StatefulWidget {
  const PublicShellScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PublicShellScreen> createState() => _PublicShellScreenState();
}

class _PublicShellScreenState extends State<PublicShellScreen> {
  PublicTab _activeTab = PublicTab.home;

  Widget _buildContent() {
    switch (_activeTab) {
      case PublicTab.home:
        return HomeScreen(appState: widget.appState);
      case PublicTab.pengambilan:
        return PickupScreen(appState: widget.appState);
      case PublicTab.pengembalian:
        return ReturnScreen(appState: widget.appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              PublicTopNav(
                activeTab: _activeTab,
                onTabChanged: (PublicTab tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                },
                isAdminLoggedIn: widget.appState.isAdminLoggedIn,
                profile: widget.appState.adminProfile,
                onLoginTap: widget.appState.goToRoleSelection,
                onDashboardTap: widget.appState.goToAdmin,
                onLogoutTap: () => _confirmLogout(context),
                onBrandTap: widget.appState.goToRoleSelection,
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: <Widget>[
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFF87171),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun administrator?',
            style: TextStyle(
              color: AppColors.slate600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.slate500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.appState.logoutAdmin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
