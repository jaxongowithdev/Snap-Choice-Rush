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
    {'icon': Icons.auto_stories, 'title': 'Primer Nest', 'description': 'Stage every lesson tray before the bell. Know which reader lives in which kit.'},
    {'icon': Icons.category_outlined, 'title': 'Twelve kinds of kit', 'description': 'Readers, flashcards, manipulatives, maps — file each piece the way you actually teach it.'},
    {'icon': Icons.photo_camera_outlined, 'title': 'Snap the cover', 'description': 'Photograph a workbook, a card deck, or a science tray so you remember the exact edition you own.'},
    {'icon': Icons.swap_horiz, 'title': 'Keep a lesson trace', 'description': 'Move a set from the cupboard to this week’s tray and leave a short note of why it moved.'},
    {'icon': Icons.wifi_off, 'title': 'Works at the desk', 'description': 'No account and no signal required. The catalog stays on this phone.'},
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
      backgroundColor: VisualTheme.parchment,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('SKIP', style: GoogleFonts.lexend(color: VisualTheme.ink.withValues(alpha: 0.45), letterSpacing: 1.4)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: VisualTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page['icon'] as IconData, size: 44, color: VisualTheme.accentColor),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sourceSerif4(fontSize: 34, fontWeight: FontWeight.w700, color: VisualTheme.ink),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(fontSize: 16, height: 1.5, color: VisualTheme.ink.withValues(alpha: 0.7)),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  ...List.generate(
                    _pages.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? VisualTheme.secondaryColor : VisualTheme.sand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Open the nest' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
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
