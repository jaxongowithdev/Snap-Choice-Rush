import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';
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
    {'folio': 'i', 'title': 'Cram Binder', 'body': 'A three-ring catalog for exam week. One spine per subject. Know which paper sits in which stack.'},
    {'folio': 'ii', 'title': 'Twelve kinds', 'body': 'Past papers, flash decks, formulae, rubrics — file each drill the way you actually study it.'},
    {'folio': 'iii', 'title': 'Snap the cover', 'body': 'Photograph a packet, a card deck, or a formula sheet so you remember the exact edition you own.'},
    {'folio': 'iv', 'title': 'Move between spines', 'body': 'Shift a deck from SAT Math to the Friday mock and leave a short note of why it moved.'},
    {'folio': 'v', 'title': 'Works at the library', 'body': 'No account and no signal. The binder stays on this phone.'},
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
      body: BinderShell(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('SKIP', style: GoogleFonts.ibmPlexMono(color: VisualTheme.ink.withValues(alpha: 0.4), letterSpacing: 1.4)),
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
                          Text(page['folio'] as String, style: GoogleFonts.libreBaskerville(fontSize: 44, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                          const SizedBox(height: 8),
                          Text(page['title'] as String, style: GoogleFonts.libreBaskerville(fontSize: 34, fontWeight: FontWeight.w700, height: 1.1)),
                          const SizedBox(height: 16),
                          Text(page['body'] as String, style: GoogleFonts.ibmPlexSans(fontSize: 16, height: 1.55)),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Text('p. ${_currentPage + 1}', style: GoogleFonts.ibmPlexMono(fontSize: 12)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _finish();
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                        }
                      },
                      child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE BINDER' : 'TURN →', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
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
