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
    {'act': 'ACT I', 'title': 'Prompt Booth', 'body': 'A drama catalog for the week. One crate per production. Know which script sits in which booth before opening night.'},
    {'act': 'ACT II', 'title': 'Twelve kinds', 'body': 'Scripts, roles, props, costumes — file each piece the way your class actually stages it.'},
    {'act': 'ACT III', 'title': 'Snap the bill', 'body': 'Photograph a prompt book, a costume rack, or a prop crate so you remember the exact edition in the wings.'},
    {'act': 'ACT IV', 'title': 'Call a cue', 'body': 'Move a role from the rehearsal crate to the opening-night stack and leave a short note of why it moved.'},
    {'act': 'ACT V', 'title': 'Works offline', 'body': 'No account and no signal. The booth stays on this phone.'},
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
      backgroundColor: VisualTheme.velvet,
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
                  child: Text('SKIP', style: GoogleFonts.libreFranklin(color: VisualTheme.cream.withValues(alpha: 0.4), letterSpacing: 1.6)),
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
                        Text(page['act'] as String, style: GoogleFonts.cinzel(fontSize: 13, letterSpacing: 3, color: VisualTheme.secondaryColor)),
                        const SizedBox(height: 16),
                        Text(page['title'] as String, textAlign: TextAlign.center, style: GoogleFonts.cinzel(fontSize: 34, fontWeight: FontWeight.w600, color: VisualTheme.cream, height: 1.15)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, textAlign: TextAlign.center, style: GoogleFonts.libreFranklin(fontSize: 16, height: 1.5, color: VisualTheme.cream.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('scene ${_currentPage + 1}', style: GoogleFonts.libreFranklin(color: VisualTheme.cream.withValues(alpha: 0.4))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE HOUSE' : 'NEXT SCENE →', style: GoogleFonts.cinzel(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
