import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppConfigUI {
  AppConfigUI._();

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      // Azul Material vibrante e profissional
      primary: const Color(0xFF2196F3), // Azul Material vibrante
      primaryContainer: const Color(0xFF1976D2), // Azul mais escuro
      // Ciano profissional como secundário
      secondary: const Color(0xFF00BCD4), // Ciano profissional
      secondaryContainer: const Color(0xFF0097A7), // Ciano mais escuro
      // Verde para sucesso
      tertiary: const Color(0xFF4CAF50), // Verde sucesso
      // Fundo escuro suave
      surface: const Color(0xFF121212), // Material Design dark surface
      // Vermelho para erros
      error: const Color(0xFFEF5350),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: const Color(0xFF2196F3),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF42A5F5), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white60),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2196F3),
        elevation: 4,
        shadowColor: const Color(0xFF64B5F6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shadowColor: const Color(0xFF2196F3).withAlpha(30),
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF42A5F5).withAlpha(20),
          width: 1,
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Exo2',
    splashColor: const Color(0xFF2196F3).withAlpha(30),
    highlightColor: const Color(0xFF42A5F5).withAlpha(20),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Exo2',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 1.2,
        color: Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF00BCD4),
      selectionColor: Color(0xFF00BCD4),
      selectionHandleColor: Color(0xFF00BCD4),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF2196F3),
      linearTrackColor: Color(0xFF42A5F5),
      strokeCap: StrokeCap.round,
      refreshBackgroundColor: Color(0xFF1E1E1E),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      collapsedBackgroundColor: Color(0xFF121212),
      tilePadding: EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: EdgeInsets.all(0),
      expandedAlignment: Alignment.topLeft,
      iconColor: Color(0xFF2196F3),
      collapsedIconColor: Color(0xFF42A5F5),
      textColor: Colors.white,
      collapsedTextColor: Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFF2196F3), width: 1),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFF42A5F5).withAlpha(30), width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: const Color(0xFF00BCD4), // Ciano profissional
      unselectedItemColor: Colors.white60,
      selectedIconTheme: const IconThemeData(size: 26, opacity: 1),
      unselectedIconTheme: const IconThemeData(size: 22, opacity: 0.7),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Exo2',
        fontSize: 11,
        letterSpacing: 0.3,
      ),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 8,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        StadiumBorder(),
      ),
      surfaceTintColor: const Color(0xFF2196F3).withAlpha(10),
      shadowColor: const Color(0xFF2196F3).withAlpha(30),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFF42A5F5).withAlpha(100),
      thickness: 1,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF2196F3);
            }
            return const Color(0xFF1E1E1E);
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white70;
          },
        ),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      // Azul mais escuro para melhor contraste
      primary: const Color(0xFF1976D2), // Azul escuro
      primaryContainer: const Color(0xFFBBDEFB), // Azul muito claro
      // Ciano escuro como secundário
      secondary: const Color(0xFF0097A7), // Ciano escuro
      secondaryContainer: const Color(0xFFB2EBF2), // Ciano claro
      // Verde para sucesso
      tertiary: const Color(0xFF388E3C), // Verde escuro
      // Fundo muito claro neutro
      surface: const Color(0xFFFAFAFA), // Branco quente
      // Vermelho para erros
      error: const Color(0xFFD32F2F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF212121), // Preto suave
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: const Color(0xFF1976D2),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF90CAF9), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF1976D2), width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Color(0xFF424242)),
      hintStyle: TextStyle(color: Color(0xFF757575)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 2,
        shadowColor: const Color(0xFF64B5F6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: const Color(0xFF1976D2).withAlpha(15),
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFE3F2FD),
          width: 1,
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Exo2',
    splashColor: const Color(0xFF1976D2).withAlpha(20),
    highlightColor: const Color(0xFF42A5F5).withAlpha(15),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Exo2',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        letterSpacing: 1.2,
        color: Color(0xFF212121),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF00B4D8),
      selectionColor: Color(0xFF00FFFF),
      selectionHandleColor: Color(0xFF00B4D8),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Color(0xFF1976D2),
      linearTrackColor: Color(0xFF90CAF9).withAlpha(50),
      circularTrackColor: Color(0xFF90CAF9).withAlpha(30),
      refreshBackgroundColor: Colors.white,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      tilePadding: EdgeInsets.symmetric(horizontal: 8),
      childrenPadding: EdgeInsets.all(0),
      expandedAlignment: Alignment.topLeft,
      iconColor: Color(0xFF1976D2),
      collapsedIconColor: Color(0xFF42A5F5),
      textColor: Color(0xFF212121),
      collapsedTextColor: Color(0xFF616161),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFF1976D2), width: 1),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Color(0xFF90CAF9), width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1976D2), // Azul escuro
      unselectedItemColor: const Color(0xFF757575),
      selectedIconTheme: const IconThemeData(size: 26, opacity: 1),
      unselectedIconTheme: const IconThemeData(size: 22, opacity: 0.7),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Exo2',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Exo2',
        fontSize: 11,
        letterSpacing: 0.3,
      ),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: Colors.white,
      elevation: 6,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        StadiumBorder(),
      ),
      surfaceTintColor: const Color(0xFF1976D2).withAlpha(5),
      shadowColor: const Color(0xFF64B5F6).withAlpha(20),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    dividerTheme: DividerThemeData(
      color: Color(0xFFBDBDBD),
      thickness: 1,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1976D2);
            }
            return Colors.white;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return const Color(0xFF424242);
          },
        ),
      ),
    ),
  );
}
