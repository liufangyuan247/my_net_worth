import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // 设置状态栏颜色
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
      ),
    );

    final customLightTheme = getAppTheme(darkMode: false).copyWith(
      // 增强TabBar视觉对比
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );

    final customDarkTheme = getAppTheme(darkMode: true).copyWith(
      // 增强TabBar视觉对比
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );

    return MaterialApp(
      title: '资产净值管理',
      theme: customLightTheme,
      darkTheme: customDarkTheme,
      themeMode: _themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
