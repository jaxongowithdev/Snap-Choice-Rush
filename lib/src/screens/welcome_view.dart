import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';
import 'dashboard_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    {'lane': '1', 'title': 'Cone Yard', 'body': 'A PE journal for the gym. One cage per station. Know which piece sits in which cart before the period starts.'},
    {'lane': '2', 'title': 'Twelve kits', 'body': 'Balls, cones, pinnies, mats — file each kit the way your gym closet actually runs.'},
    {'lane': '3', 'title': 'Snap the cone', 'body': 'Photograph a cage, a clipboard, or a station kit so you remember the exact piece on the floor.'},
    {'lane': '4', 'title': 'Log a move', 'body': 'Shift a kit from the ball cage to station three and leave a short note of why it moved.'},
    {'lane': '5', 'title': 'Works offline', 'body': 'No account and no signal. The roster stays on this phone.'},
  ];

  Future<void> _finish() async {
    final storage = StorageManager.instance;
    final prefs = await storage.getPreferences();
    await storage.updatePreferences(prefs.copyWith(showOnboarding: false));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardView(onSettingsChanged: () {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisualTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('SKIP', style: GoogleFonts.oswald(color: VisualTheme.court.withValues(alpha: 0.4), letterSpacing: 2)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: VisualTheme.secondaryColor,
                          child: Text('LANE ${page['lane']}', style: GoogleFonts.oswald(fontSize: 14, letterSpacing: 2, color: VisualTheme.court)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.oswald(fontSize: 44, color: VisualTheme.court, height: 0.95)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.karla(fontSize: 16, height: 1.5, color: VisualTheme.court.withValues(alpha: 0.82))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('lane ${_currentPage + 1} of 5', style: GoogleFonts.oswald(color: VisualTheme.court.withValues(alpha: 0.4), letterSpacing: 1)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'BLOW THE WHISTLE' : 'NEXT LANE →', style: GoogleFonts.oswald(color: VisualTheme.accentColor, fontSize: 16, letterSpacing: 0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
