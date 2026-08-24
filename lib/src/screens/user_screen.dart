import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import 'dashboard_view.dart';
import 'welcome_view.dart';
import '../utils/visual_theme.dart';
import '../models/user_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _storage = StorageManager.instance;
  bool _isInitialized = false;
  UserPreferences? _preferences;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Starting Dewey Nook initialization...');
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
        _errorMessage = e.toString();
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
      title: 'Dewey Nook',
      debugShowCheckedModeBanner: false,
      theme: VisualTheme.lightTheme,
      darkTheme: VisualTheme.darkTheme,
      themeMode: themeMode,
      home: Builder(
        builder: (context) {
          if (!_isInitialized || _preferences == null) {
            return Scaffold(
              backgroundColor: VisualTheme.primaryColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dewey Nook', style: GoogleFonts.libreBaskerville(color: VisualTheme.paper, fontSize: 32, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 8),
                    Text('Opening the catalog…', style: GoogleFonts.outfit(color: VisualTheme.paper.withValues(alpha: 0.75))),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text('Error: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                    ],
                  ],
                ),
              ),
            );
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
