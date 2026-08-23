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
    {'kicker': '01', 'title': 'Period Slate', 'body': 'A chalkboard for the week. One row per period. Know what sits on the desk before the bell.'},
    {'kicker': '02', 'title': 'Twelve kinds', 'body': 'Handouts, texts, labs, assessments — file each piece the way the period actually runs.'},
    {'kicker': '03', 'title': 'Snap the stack', 'body': 'Photograph a worksheet, a lab bin, or a hall pass so you remember the exact set you own.'},
    {'kicker': '04', 'title': 'Shift between periods', 'body': 'Move a kit from Period 2 to Period 5 and leave a short note of why it moved.'},
    {'kicker': '05', 'title': 'Works in the hallway', 'body': 'No account and no signal. The board stays on this phone.'},
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('SKIP', style: GoogleFonts.syne(color: VisualTheme.chalk.withValues(alpha: 0.45), letterSpacing: 1.6, fontWeight: FontWeight.w800)),
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
                        Text(page['kicker'] as String, style: GoogleFonts.syne(fontSize: 48, fontWeight: FontWeight.w800, color: VisualTheme.accentColor, height: 1)),
                        const SizedBox(height: 8),
                        Container(width: 48, height: 3, color: VisualTheme.secondaryColor),
                        const SizedBox(height: 22),
                        Text(page['title'] as String, style: GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w800, color: VisualTheme.chalk, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.manrope(fontSize: 16, height: 1.5, color: VisualTheme.chalk.withValues(alpha: 0.72))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('${_currentPage + 1} / ${_pages.length}', style: GoogleFonts.syne(color: VisualTheme.chalk.withValues(alpha: 0.5), letterSpacing: 1.2)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE BOARD' : 'NEXT →', style: GoogleFonts.syne(color: VisualTheme.accentColor, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
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
