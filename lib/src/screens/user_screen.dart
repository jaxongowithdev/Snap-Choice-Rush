import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';
import 'dashboard_view.dart';
import 'welcome_view.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _storage = StorageManager.instance;
  bool _isInitialized = false;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Kettleleaf opening the desk…');
      await _storage.database;
      final prefs = await _storage.getPreferences();
      AppAppearance.apply(prefs.theme);
      setState(() {
        _preferences = prefs;
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      AppAppearance.apply('system');
      setState(() {
        _preferences = UserPreferences();
        _isInitialized = true;
      });
    }
  }

  Future<void> _reloadPreferences() async {
    try {
      final prefs = await _storage.getPreferences();
      AppAppearance.apply(prefs.theme);
      setState(() => _preferences = prefs);
    } catch (e) {
      debugPrint('Error reloading preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppAppearance.listenable,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Kettleleaf',
          debugShowCheckedModeBanner: false,
          theme: VisualTheme.lightTheme,
          darkTheme: VisualTheme.darkTheme,
          themeMode: themeMode,
          home: Builder(
            builder: (context) {
              if (!_isInitialized || _preferences == null) {
                return const _BootScreen();
              }
              return _preferences!.showOnboarding
                  ? WelcomeView(onSettingsChanged: _reloadPreferences)
                  : DashboardView(onSettingsChanged: _reloadPreferences);
            },
          ),
          routes: {
            '/dashboard': (context) => DashboardView(onSettingsChanged: _reloadPreferences),
          },
        );
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisualTheme.clay,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_food_beverage_rounded, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 22),
            Text('Kettleleaf', style: VisualTheme.display(34, color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              'Laying out the paper…',
              style: VisualTheme.body(15, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
