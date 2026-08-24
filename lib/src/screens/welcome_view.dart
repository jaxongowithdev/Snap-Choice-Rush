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
    {'st': 'I', 'title': 'Ink Stanza', 'body': 'A poetry workshop for the week. One folio per class. Know which verse sits in which drawer before the reading.'},
    {'st': 'II', 'title': 'Twelve kinds', 'body': 'Sonnets, haiku, spoken word, anthologies — file each piece the way your workshop actually writes it.'},
    {'st': 'III', 'title': 'Snap the leaf', 'body': 'Photograph a broadside, a journal, or a sealed copy so you remember the exact edition on the desk.'},
    {'st': 'IV', 'title': 'Pass a folio', 'body': 'Move a sonnet from the class folio to the reading night stack and leave a short note of why it moved.'},
    {'st': 'V', 'title': 'Works offline', 'body': 'No account and no signal. The desk stays on this phone.'},
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
      backgroundColor: VisualTheme.ink,
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
                  child: Text('SKIP', style: GoogleFonts.figtree(color: VisualTheme.washi.withValues(alpha: 0.4), letterSpacing: 1.6)),
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
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: VisualTheme.primaryColor, width: 1.4),
                          ),
                          child: Text(page['st'] as String, style: GoogleFonts.spectral(fontSize: 16, color: VisualTheme.primaryColor)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.spectral(fontSize: 40, fontStyle: FontStyle.italic, color: VisualTheme.washi, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.figtree(fontSize: 16, height: 1.5, color: VisualTheme.washi.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('stanza ${_currentPage + 1}', style: GoogleFonts.figtree(color: VisualTheme.washi.withValues(alpha: 0.4))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE DESK' : 'TURN THE LEAF →', style: GoogleFonts.figtree(color: VisualTheme.primaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
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
