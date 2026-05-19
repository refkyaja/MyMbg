import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../utils/app_constants.dart';
import 'admin/admin_shell_screen.dart';
import 'auth/login_screen.dart';
import 'auth/role_selection_screen.dart';
import 'public/public_shell_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (BuildContext context, Widget? child) {
        switch (appState.currentView) {
          case AppView.roleSelection:
            return RoleSelectionScreen(appState: appState);
          case AppView.login:
            return LoginScreen(appState: appState);
          case AppView.admin:
            return AdminShellScreen(appState: appState);
          case AppView.publicPortal:
            return PublicShellScreen(appState: appState);
        }
      },
    );
  }
}
