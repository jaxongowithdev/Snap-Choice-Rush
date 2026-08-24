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
    {'timer': '1', 'title': 'Amber Tray', 'body': 'A darkroom journal for photo class. One tray per paper grade. Know which print sits in which bath before critique.'},
    {'timer': '2', 'title': 'Twelve kinds', 'body': 'Negatives, prints, contacts, chemistry — file each piece the way your bench actually runs.'},
    {'timer': '3', 'title': 'Snap the print', 'body': 'Photograph a wet print, a film strip, or a paper box so you remember the exact sheet in the tray.'},
    {'timer': '4', 'title': 'Log a move', 'body': 'Shift a print from the holding bath to the drying rack and leave a short note of why it moved.'},
    {'timer': '5', 'title': 'Works offline', 'body': 'No account and no signal. The catalog stays on this phone, even with the lights out.'},
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
      backgroundColor: VisualTheme.fog,
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
                  child: Text('SKIP', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor.withValues(alpha: 0.4), letterSpacing: 2)),
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
                        Text('TIMER ${page['timer']}', style: GoogleFonts.ibmPlexMono(fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.w600, color: VisualTheme.primaryColor)),
                        const SizedBox(height: 16),
                        Text(page['title'] as String, style: GoogleFonts.fraunces(fontSize: 40, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: VisualTheme.print, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.ibmPlexMono(fontSize: 14, height: 1.55, color: VisualTheme.hypo)),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('0${_currentPage + 1} / 05', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor.withValues(alpha: 0.5))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'LIGHTS OUT' : 'ADVANCE →', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
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
