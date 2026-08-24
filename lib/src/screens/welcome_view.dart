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
    {'card': '01', 'title': 'Lemma Box', 'body': 'A vocab desk for the week. One deck per unit. Know which lemma sits in which box before the quiz.'},
    {'card': '02', 'title': 'Twelve kinds', 'body': 'Nouns, roots, idioms, spelling — file each card the way your class actually studies it.'},
    {'card': '03', 'title': 'Snap the card', 'body': 'Photograph a deck, a word wall, or a quiz stack so you remember the exact set on the shelf.'},
    {'card': '04', 'title': 'Shift a card', 'body': 'Move a lemma from the class deck to the quiz stack and leave a short note of why it moved.'},
    {'card': '05', 'title': 'Works offline', 'body': 'No account and no signal. The box stays on this phone.'},
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
                  child: Text('SKIP', style: GoogleFonts.atkinsonHyperlegible(color: VisualTheme.manila.withValues(alpha: 0.4), letterSpacing: 1.6)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: VisualTheme.secondaryColor, width: 4)),
                            color: VisualTheme.manila,
                          ),
                          child: Text('CARD ${page['card']}', style: GoogleFonts.atkinsonHyperlegible(fontSize: 12, fontWeight: FontWeight.w800, color: VisualTheme.primaryColor)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.literata(fontSize: 38, fontWeight: FontWeight.w700, color: VisualTheme.manila, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.atkinsonHyperlegible(fontSize: 16, height: 1.5, color: VisualTheme.manila.withValues(alpha: 0.82))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('card ${_currentPage + 1} of 5', style: GoogleFonts.atkinsonHyperlegible(color: VisualTheme.manila.withValues(alpha: 0.45))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE BOX' : 'FLIP →', style: GoogleFonts.atkinsonHyperlegible(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
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
