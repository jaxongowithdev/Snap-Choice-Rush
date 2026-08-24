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
    {'fix': 'N 41°', 'title': 'Meridian Desk', 'body': 'A classroom atlas for the week. One folio per unit. Know which map sits in which drawer before the next lesson.'},
    {'fix': 'E 12', 'title': 'Twelve kinds', 'body': 'Continents, capitals, rivers, globes — file each piece the way your class actually studies it.'},
    {'fix': 'S 08', 'title': 'Snap the fold', 'body': 'Photograph a wall map, a globe, or a field pin so you remember the exact edition on the shelf.'},
    {'fix': 'W 74', 'title': 'Log a shift', 'body': 'Move a river chart from the wall folio to the field satchel and leave a short note of why it moved.'},
    {'fix': 'CABIN', 'title': 'Works offline', 'body': 'No account and no signal. The desk stays on this phone.'},
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
                  child: Text('SKIP', style: GoogleFonts.outfit(color: VisualTheme.sand.withValues(alpha: 0.45), letterSpacing: 1.6)),
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
                            border: Border.all(color: VisualTheme.secondaryColor),
                          ),
                          child: Text(page['fix'] as String, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: VisualTheme.secondaryColor)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.fraunces(fontSize: 38, fontWeight: FontWeight.w600, color: VisualTheme.sand, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: VisualTheme.sand.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('fix ${_currentPage + 1} of 5', style: GoogleFonts.outfit(color: VisualTheme.sand.withValues(alpha: 0.45))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE DESK' : 'NEXT BEARING →', style: GoogleFonts.outfit(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
