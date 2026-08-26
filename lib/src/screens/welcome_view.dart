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
    {'star': 'I', 'title': 'Star Loci', 'body': 'A memory palace for the night sky. One room per constellation. Know which card sits in which palace before the quiz.'},
    {'star': 'II', 'title': 'Twelve kinds', 'body': 'Planets, myths, numbers, voyages — file each locus the way your astronomy class actually memorizes.'},
    {'star': 'III', 'title': 'Snap the sky', 'body': 'Photograph a chart, a planet card, or a palace sketch so you remember the exact image in the room.'},
    {'star': 'IV', 'title': 'Move a locus', 'body': 'Shift a card from the planet room to the myth hall and leave a short note of why it moved.'},
    {'star': 'V', 'title': 'Works offline', 'body': 'No account and no signal. The sky stays on this phone.'},
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
      backgroundColor: VisualTheme.voidNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('SKIP', style: GoogleFonts.cinzel(color: VisualTheme.chart.withValues(alpha: 0.35), letterSpacing: 2)),
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
                      children: [
                        const Spacer(),
                        Text('STAR ${page['star']}', style: GoogleFonts.cinzel(fontSize: 12, letterSpacing: 3, color: VisualTheme.secondaryColor)),
                        const SizedBox(height: 16),
                        Text(page['title'] as String, textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 40, color: VisualTheme.chart, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 16, height: 1.5, color: VisualTheme.chart.withValues(alpha: 0.82))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('star ${_currentPage + 1} of 5', style: GoogleFonts.cinzel(color: VisualTheme.chart.withValues(alpha: 0.35), letterSpacing: 1, fontSize: 11)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE DOME' : 'NEXT STAR →', style: GoogleFonts.cinzel(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w700, letterSpacing: 1)),
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
