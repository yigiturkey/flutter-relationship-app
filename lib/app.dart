import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'providers/auth_provider.dart';

class RelationshipApp extends StatelessWidget {
  const RelationshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp(
          title: 'İlişki Analizi',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}