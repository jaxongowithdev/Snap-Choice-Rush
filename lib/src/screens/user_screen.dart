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
      debugPrint('Orbit Recall booting…');
      await _storage.database;
      final prefs = await _storage.getPreferences();
      setState(() {
        _preferences = prefs;
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing app: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _preferences = UserPreferences();
        _isInitialized = true;
      });
    }
  }

  Future<void> _reloadPreferences() async {
    try {
      final prefs = await _storage.getPreferences();
      setState(() => _preferences = prefs);
    } catch (e) {
      debugPrint('Error reloading preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = ThemeMode.system;
    if (_preferences != null) {
      switch (_preferences!.theme) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }
    }

    return MaterialApp(
      title: 'Orbit Recall',
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
              ? const WelcomeView()
              : DashboardView(onSettingsChanged: _reloadPreferences);
        },
      ),
      routes: {
        '/dashboard': (context) => DashboardView(onSettingsChanged: _reloadPreferences),
      },
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisualTheme.nova,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.bolt_rounded, size: 46, color: Colors.white),
            ),
            const SizedBox(height: 22),
            Text('Orbit Recall', style: VisualTheme.display(34, color: Colors.white)),
            const SizedBox(height: 6),
            Text(
              'Spinning up the training deck…',
              style: VisualTheme.body(15, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
