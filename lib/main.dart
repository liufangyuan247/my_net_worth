import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/portfolio_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if this is the first run
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('is_first_run') ?? true;

  if (isFirstRun) {
    final portfolioService = PortfolioService();
    await portfolioService.initializeWithSampleData();
    await prefs.setBool('is_first_run', false);
  }

  runApp(const MyNetWorthApp());
}

class MyNetWorthApp extends StatefulWidget {
  const MyNetWorthApp({Key? key}) : super(key: key);

  @override
  State<MyNetWorthApp> createState() => _MyNetWorthAppState();

  static _MyNetWorthAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_MyNetWorthAppState>()!;
  }
}

class _MyNetWorthAppState extends State<MyNetWorthApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '资产净值管理',
      theme: getAppTheme(darkMode: false),
      darkTheme: getAppTheme(darkMode: true),
      themeMode: _themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
