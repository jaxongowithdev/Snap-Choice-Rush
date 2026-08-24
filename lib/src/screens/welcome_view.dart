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
    {'card': '1', 'title': 'Dewey Nook', 'body': 'A reading journal for the workshop. One bin per shelf. Know which title sits in which crate before independent reading.'},
    {'card': '2', 'title': 'Twelve kinds', 'body': 'Picture, chapter, nonfiction, series — file each kit the way your classroom library actually runs.'},
    {'card': '3', 'title': 'Snap the spine', 'body': 'Photograph a bin, a checkout card, or a book kit so you remember the exact title on the shelf.'},
    {'card': '4', 'title': 'Log a move', 'body': 'Shift a title from the chapter bin to the teacher crate and leave a short note of why it moved.'},
    {'card': '5', 'title': 'Works offline', 'body': 'No account and no signal. The catalog stays on this phone.'},
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
      backgroundColor: VisualTheme.manila,
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
                  child: Text('SKIP', style: GoogleFonts.outfit(color: VisualTheme.ink.withValues(alpha: 0.35), letterSpacing: 2)),
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
                          child: Text('CARD ${page['card']}', style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w800, color: VisualTheme.paper)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.libreBaskerville(fontSize: 40, fontStyle: FontStyle.italic, color: VisualTheme.ink, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: VisualTheme.ink.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('card ${_currentPage + 1} of 5', style: GoogleFonts.outfit(color: VisualTheme.ink.withValues(alpha: 0.4))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE NOOK' : 'NEXT CARD →', style: GoogleFonts.outfit(color: VisualTheme.primaryColor, fontWeight: FontWeight.w800)),
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
