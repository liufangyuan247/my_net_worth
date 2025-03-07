import 'package:flutter/material.dart';

class AppThemeColors {
  // 主要颜色
  static const primaryLight = Color(0xFF1976D2); // 蓝色
  static const primaryDark = Color(0xFF90CAF9); // 浅蓝色

  // 次要颜色
  static const secondaryLight = Color(0xFF26A69A); // 绿松石色
  static const secondaryDark = Color(0xFF80CBC4); // 浅绿松石色

  // 背景颜色
  static const backgroundLight = Color(0xFFFAFAFA);
  static const backgroundDark = Color(0xFF121212);

  // 卡片颜色
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E1E1E);

  // 资产类型颜色
  static const stockColorLight = Color(0xFF1565C0); // 深蓝色
  static const stockColorDark = Color(0xFF42A5F5); // 亮蓝色

  static const cryptoColorLight = Color(0xFFE65100); // 橙色
  static const cryptoColorDark = Color(0xFFFFB74D); // 亮橙色

  static const cashColorLight = Color(0xFF2E7D32); // 绿色
  static const cashColorDark = Color(0xFF81C784); // 亮绿色

  // 增长颜色（利润）
  static const positiveGrowthLight = Color(0xFF388E3C);
  static const positiveGrowthDark = Color(0xFF4CAF50);

  // 下降颜色（损失）
  static const negativeGrowthLight = Color(0xFFC62828);
  static const negativeGrowthDark = Color(0xFFE57373);
}

ThemeData getAppTheme({bool darkMode = false}) {
  return darkMode ? _getDarkTheme() : _getLightTheme();
}

ThemeData _getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: AppThemeColors.primaryLight,
    colorScheme: ColorScheme.light(
      primary: AppThemeColors.primaryLight,
      secondary: AppThemeColors.secondaryLight,
      background: AppThemeColors.backgroundLight,
    ),
    scaffoldBackgroundColor: AppThemeColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppThemeColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppThemeColors.cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppThemeColors.primaryLight,
        side: const BorderSide(color: AppThemeColors.primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppThemeColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppThemeColors.primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
      indent: 0,
      endIndent: 0,
    ),
    textTheme: const TextTheme(
      headline4: TextStyle(
        color: Color(0xFF212121),
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headline5: TextStyle(
        color: Color(0xFF212121),
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headline6: TextStyle(
        color: Color(0xFF212121),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      subtitle1: TextStyle(
        color: Color(0xFF757575),
        fontSize: 16,
      ),
      subtitle2: TextStyle(
        color: Color(0xFF757575),
        fontSize: 14,
      ),
      bodyText1: TextStyle(
        color: Color(0xFF212121),
        fontSize: 16,
      ),
      bodyText2: TextStyle(
        color: Color(0xFF212121),
        fontSize: 14,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppThemeColors.primaryLight,
      unselectedItemColor: Color(0xFF757575),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppThemeColors.primaryLight;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppThemeColors.primaryLight.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
  );
}

ThemeData _getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppThemeColors.primaryDark,
    colorScheme: ColorScheme.dark(
      primary: AppThemeColors.primaryDark,
      secondary: AppThemeColors.secondaryDark,
      background: AppThemeColors.backgroundDark,
    ),
    scaffoldBackgroundColor: AppThemeColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppThemeColors.cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeColors.primaryDark,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppThemeColors.primaryDark,
        side: const BorderSide(color: AppThemeColors.primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppThemeColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: AppThemeColors.primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fillColor: const Color(0xFF2C2C2C),
      filled: true,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      indent: 0,
      endIndent: 0,
    ),
    textTheme: const TextTheme(
      headline4: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headline5: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headline6: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      subtitle1: TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 16,
      ),
      subtitle2: TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 14,
      ),
      bodyText1: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      selectedItemColor: AppThemeColors.primaryDark,
      unselectedItemColor: Color(0xFFBDBDBD),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppThemeColors.primaryDark;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppThemeColors.primaryDark.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
  );
}

// 资产类型颜色获取函数
Color getAssetTypeColor(BuildContext context, String assetType) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  switch (assetType) {
    case 'stock':
      return isDark
          ? AppThemeColors.stockColorDark
          : AppThemeColors.stockColorLight;
    case 'crypto':
      return isDark
          ? AppThemeColors.cryptoColorDark
          : AppThemeColors.cryptoColorLight;
    case 'cash':
      return isDark
          ? AppThemeColors.cashColorDark
          : AppThemeColors.cashColorLight;
    default:
      return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
  }
}

// 获取正负增长颜色
Color getGrowthColor(BuildContext context, double value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (value > 0) {
    return isDark
        ? AppThemeColors.positiveGrowthDark
        : AppThemeColors.positiveGrowthLight;
  } else if (value < 0) {
    return isDark
        ? AppThemeColors.negativeGrowthDark
        : AppThemeColors.negativeGrowthLight;
  } else {
    return isDark ? Colors.white70 : Colors.black54;
  }
}
