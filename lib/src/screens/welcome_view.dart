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
    {'stop': '1', 'title': 'Press Leaf', 'body': 'A nature journal for the week. One press per hike. Know which specimen sits in which folio before the unit walk.'},
    {'stop': '2', 'title': 'Twelve kinds', 'body': 'Leaves, flowers, bark, rocks — file each find the way your class actually collects it.'},
    {'stop': '3', 'title': 'Snap the press', 'body': 'Photograph a leaf, a trail find, or a field satchel so you remember the exact slip in the press.'},
    {'stop': '4', 'title': 'Log a move', 'body': 'Shift a specimen from the field press to the classroom folio and leave a short note of why it moved.'},
    {'stop': '5', 'title': 'Works offline', 'body': 'No account and no signal. The journal stays on this phone.'},
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
      backgroundColor: VisualTheme.bark,
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
                  child: Text('SKIP', style: GoogleFonts.nunitoSans(color: VisualTheme.cream.withValues(alpha: 0.4), letterSpacing: 1.6)),
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
                        Text('STOP ${page['stop']}', style: GoogleFonts.nunitoSans(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
                        const SizedBox(height: 14),
                        Text(page['title'] as String, style: GoogleFonts.newsreader(fontSize: 40, fontStyle: FontStyle.italic, color: VisualTheme.cream, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.nunitoSans(fontSize: 16, height: 1.5, color: VisualTheme.cream.withValues(alpha: 0.8))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('stop ${_currentPage + 1} of 5', style: GoogleFonts.nunitoSans(color: VisualTheme.cream.withValues(alpha: 0.4))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE PRESS' : 'NEXT STOP →', style: GoogleFonts.nunitoSans(color: VisualTheme.accentColor, fontWeight: FontWeight.w800)),
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
