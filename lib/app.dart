import 'package:flutter/material.dart';

import 'screens/root_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';

class MyMbgApp extends StatefulWidget {
  const MyMbgApp({super.key});
 
   @override
   State<MyMbgApp> createState() => _MyMbgAppState();
 }
 
 class _MyMbgAppState extends State<MyMbgApp> {
   final AppState _appState = AppState();
 
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       title: 'MyMbg',
      theme: AppTheme.lightTheme,
      home: SplashScreen(
        nextScreen: RootScreen(appState: _appState),
      ),
    );
  }
}
