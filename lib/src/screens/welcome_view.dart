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
    {'mv': 'I.', 'title': 'Etude Hall', 'body': 'A recital catalog for the week. One book per studio. Know which score sits in which stand before the concert.'},
    {'mv': 'II.', 'title': 'Twelve kinds', 'body': 'Scores, etudes, methods, recordings — file each piece the way you actually practice it.'},
    {'mv': 'III.', 'title': 'Snap the cover', 'body': 'Photograph a method book, a part, or a reed case so you remember the exact edition you own.'},
    {'mv': 'IV.', 'title': 'Cue a move', 'body': 'Shift an etude from the studio stand to the recital folder and leave a short note of why it moved.'},
    {'mv': 'V.', 'title': 'Works backstage', 'body': 'No account and no signal. The hall stays on this phone.'},
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
                  child: Text('SKIP', style: GoogleFonts.workSans(color: VisualTheme.ivory.withValues(alpha: 0.45), letterSpacing: 1.6)),
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
                        Text(page['mv'] as String, style: GoogleFonts.cormorantGaramond(fontSize: 42, fontStyle: FontStyle.italic, color: VisualTheme.secondaryColor)),
                        Text(page['title'] as String, style: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.w600, color: VisualTheme.ivory, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.workSans(fontSize: 16, height: 1.5, color: VisualTheme.ivory.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('mv. ${_currentPage + 1}', style: GoogleFonts.workSans(color: VisualTheme.ivory.withValues(alpha: 0.45))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE HALL' : 'ATTACCA →', style: GoogleFonts.workSans(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
