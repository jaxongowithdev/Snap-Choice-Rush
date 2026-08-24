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
    {'gallery': '1', 'title': 'Time Spine', 'body': 'A history journal for the unit. One shelf per era. Know which source sits in which gallery before the test.'},
    {'gallery': '2', 'title': 'Twelve kinds', 'body': 'Ancient, maps, speeches, artifacts — file each piece the way your class actually studies it.'},
    {'gallery': '3', 'title': 'Snap the piece', 'body': 'Photograph a document, a map, or a classroom artifact so you remember the exact item on the shelf.'},
    {'gallery': '4', 'title': 'Log a move', 'body': 'Shift a source from the unit shelf to the review crate and leave a short note of why it moved.'},
    {'gallery': '5', 'title': 'Works offline', 'body': 'No account and no signal. The hall stays on this phone.'},
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
                  child: Text('SKIP', style: GoogleFonts.publicSans(color: VisualTheme.parchment.withValues(alpha: 0.35), letterSpacing: 2)),
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
                        Row(
                          children: [
                            Container(width: 28, height: 2, color: VisualTheme.secondaryColor),
                            const SizedBox(width: 10),
                            Text('GALLERY ${page['gallery']}', style: GoogleFonts.publicSans(fontSize: 12, letterSpacing: 2.4, fontWeight: FontWeight.w800, color: VisualTheme.secondaryColor)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.cormorantGaramond(fontSize: 42, fontStyle: FontStyle.italic, color: VisualTheme.parchment, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.publicSans(fontSize: 16, height: 1.5, color: VisualTheme.parchment.withValues(alpha: 0.78))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('gallery ${_currentPage + 1} of 5', style: GoogleFonts.publicSans(color: VisualTheme.parchment.withValues(alpha: 0.4))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'ENTER THE HALL' : 'NEXT GALLERY →', style: GoogleFonts.publicSans(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
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
