import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/admin/admin_header.dart';
import '../../widgets/admin/admin_sidebar.dart';
import 'classes_admin_screen.dart';
import 'dashboard_admin_screen.dart';
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

        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  child: SafeArea(
                    child: AdminSidebar(
                      activeTab: _activeTab,
                      onTabSelected: _selectTab,
                      onLogout: widget.appState.logoutAdmin,
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: <Widget>[
                if (showSidebar)
                  SizedBox(
                    width: 280,
                    child: AdminSidebar(
                      activeTab: _activeTab,
                      onTabSelected: _selectTab,
                      onLogout: widget.appState.logoutAdmin,
                    ),
                  ),
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.pageBackground,
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
    );
  }
}
