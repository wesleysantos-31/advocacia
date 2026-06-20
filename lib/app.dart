import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/menu_screen.dart';

class GestaoPrevApp extends StatelessWidget {
  const GestaoPrevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GestãoPrev - Advocacia Previdenciária',
      theme: AppTheme.theme,
      home: AuthService.estaLogado ? const MenuScreen() : const HomeScreen(),
    );
  }
}
