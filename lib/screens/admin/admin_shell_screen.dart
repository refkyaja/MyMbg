import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/admin/admin_header.dart';
import '../../widgets/admin/admin_sidebar.dart';
import 'classes_admin_screen.dart';
import 'dashboard_admin_screen.dart';
import 'feedback_admin_screen.dart';
import 'history_admin_screen.dart';
import 'menu_admin_screen.dart';
import 'monitoring_admin_screen.dart';
import 'profile_admin_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AdminTab _activeTab = AdminTab.dashboard;
  bool _isSidebarCollapsed = false;

  Widget _buildScreen() {
    switch (_activeTab) {
      case AdminTab.dashboard:
        return DashboardAdminScreen(appState: widget.appState);
      case AdminTab.menu:
        return MenuAdminScreen(appState: widget.appState);
      case AdminTab.kelas:
        return ClassesAdminScreen(appState: widget.appState);
      case AdminTab.monitoring:
        return MonitoringAdminScreen(appState: widget.appState);
      case AdminTab.riwayat:
        return HistoryAdminScreen(appState: widget.appState);
      case AdminTab.feedback:
        return FeedbackAdminScreen(appState: widget.appState);
      case AdminTab.profile:
        return ProfileAdminScreen(appState: widget.appState);
    }
  }

  void _selectTab(AdminTab tab) {
    setState(() {
      _activeTab = tab;
    });

    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (BuildContext context, Widget? child) {
        final bool showSidebar = MediaQuery.sizeOf(context).width >= 1080;
        final bool isDark = widget.appState.isAdminDarkMode;

        return AnimatedTheme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Builder(
            builder: (BuildContext context) {
              final Color bgColor = Theme.of(context).scaffoldBackgroundColor;

              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: bgColor,
                drawer: showSidebar
                    ? null
                    : Drawer(
                        backgroundColor: isDark ? AppColors.slate900 : AppColors.emerald,
                        child: SafeArea(
                          child: AdminSidebar(
                            activeTab: _activeTab,
                            onTabSelected: _selectTab,
                            onLogout: () => _confirmLogout(context),
                            isCollapsed: false,
                          ),
                        ),
                      ),
                body: SafeArea(
                  child: Row(
                    children: <Widget>[
                      if (showSidebar)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOutCubic,
                          width: _isSidebarCollapsed ? 80.0 : 280.0,
                          child: AdminSidebar(
                            activeTab: _activeTab,
                            onTabSelected: _selectTab,
                            onLogout: () => _confirmLogout(context),
                            isCollapsed: _isSidebarCollapsed,
                          ),
                        ),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bgColor,
                          ),
                          child: Column(
                            children: <Widget>[
                              AdminHeader(
                                profile: widget.appState.adminProfile,
                                onProfileTap: () => _selectTab(AdminTab.profile),
                                onBackToPortal: widget.appState.goToPublicPortal,
                                showMenuButton: !showSidebar,
                                onMenuTap: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                                isSidebarCollapsed: _isSidebarCollapsed,
                                onToggleSidebar: showSidebar
                                    ? () {
                                        setState(() {
                                          _isSidebarCollapsed = !_isSidebarCollapsed;
                                        });
                                      }
                                    : null,
                                isDark: isDark,
                                onToggleDarkMode: () {
                                  widget.appState.toggleAdminDarkMode(!isDark);
                                },
                              ),
                              Expanded(child: _buildScreen()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? AppColors.slate800 : Colors.white,
          title: Row(
            children: <Widget>[
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFF87171),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun administrator?',
            style: TextStyle(
              color: isDark ? AppColors.slate300 : AppColors.slate600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isDark ? AppColors.slate400 : AppColors.slate500,
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
