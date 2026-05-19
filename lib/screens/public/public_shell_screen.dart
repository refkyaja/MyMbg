import 'package:flutter/material.dart';

import '../../services/app_state.dart';
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
                onLogoutTap: widget.appState.logoutAdmin,
                onBrandTap: widget.appState.goToRoleSelection,
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }
}
