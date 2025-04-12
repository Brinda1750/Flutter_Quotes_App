import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quotes_app/pages/login_page.dart';
import 'package:quotes_app/pages/main_screen.dart';
import 'package:quotes_app/services/auth_service.dart';
import 'package:quotes_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => authService,
      child: const QuotesApp(),
    ),
  );
}

class QuotesApp extends StatelessWidget {
  const QuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Set to light theme as default
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.currentUser == null
              ? const LoginPage()
              : const MainScreen();
        },
      ),
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
