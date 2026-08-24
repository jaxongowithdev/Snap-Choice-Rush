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
    {'sheet': '01', 'title': 'Trace Hall', 'body': 'A drafting journal for studio class. One set per project. Know which plate sits in which portfolio before critique.'},
    {'sheet': '02', 'title': 'Twelve kinds', 'body': 'Plans, sections, elevations, details — file each drawing the way your studio actually works.'},
    {'sheet': '03', 'title': 'Snap the plate', 'body': 'Photograph a sketch, a model, or a title block so you remember the exact sheet on the board.'},
    {'sheet': '04', 'title': 'Log a move', 'body': 'Shift a plate from the working set to the critique folio and leave a short note of why it moved.'},
    {'sheet': '05', 'title': 'Works offline', 'body': 'No account and no signal. The studio catalog stays on this phone.'},
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
                  child: Text('SKIP', style: GoogleFonts.barlowCondensed(color: VisualTheme.cyan.withValues(alpha: 0.4), letterSpacing: 2)),
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
                        Text('SHEET ${page['sheet']}', style: GoogleFonts.barlowCondensed(fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.w700, color: VisualTheme.cyan)),
                        const SizedBox(height: 16),
                        Text(page['title'] as String, style: GoogleFonts.sourceSerif4(fontSize: 40, fontWeight: FontWeight.w600, color: VisualTheme.vellum, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.barlowCondensed(fontSize: 18, height: 1.45, color: VisualTheme.cyan.withValues(alpha: 0.9))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('A${_currentPage + 1} / A5', style: GoogleFonts.barlowCondensed(color: VisualTheme.cyan.withValues(alpha: 0.5), letterSpacing: 1.2)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'PIN THE BOARD' : 'NEXT SHEET →', style: GoogleFonts.barlowCondensed(color: VisualTheme.accentColor, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 16)),
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
