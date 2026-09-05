import 'package:flutter/material.dart';
import 'models/app_settings.dart';
import 'l10n/app_strings.dart';
import 'screens/home_screen.dart';
import 'screens/dua_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.loadSettings();
  await AppLocale.instance.load();

  runApp(ZikrApp(settings: settings));
}

// === ГЛАВНЫЙ ВИДЖЕТ ===
class ZikrApp extends StatelessWidget {
  final AppSettings settings;

  const ZikrApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settings, AppLocale.instance]),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zikr App',
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: MainNavigation(settings: settings),
        );
      },
    );
  }
}

// === НАВИГАЦИЯ ===
class MainNavigation extends StatefulWidget {
  final AppSettings settings;
  const MainNavigation({super.key, required this.settings});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ZikrHomePage(settings: widget.settings),
      const DuaScreen(),
      const QiblaScreen(),
      SettingsScreen(settings: widget.settings),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.fingerprint),
              label: AppLocale.instance.t('nav_tasbih')),
          NavigationDestination(
              icon: const Icon(Icons.auto_stories),
              label: AppLocale.instance.t('nav_dua')),
          NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              label: AppLocale.instance.t('nav_qibla')),
          NavigationDestination(
              icon: const Icon(Icons.settings),
              label: AppLocale.instance.t('nav_settings')),
        ],
      ),
    );
  }
}
