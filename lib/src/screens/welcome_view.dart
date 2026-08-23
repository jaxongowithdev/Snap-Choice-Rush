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
    {'tag': 'RUN 00', 'title': 'Beaker Bench', 'body': 'A lab roster for the period. One rack per kit. Know which sensor sits in which well before the bell.'},
    {'tag': 'RUN 01', 'title': 'Twelve kinds', 'body': 'Glassware, slides, safety, models — file each set the way the bench actually runs.'},
    {'tag': 'RUN 02', 'title': 'Snap the tray', 'body': 'Photograph a goggle bin, a slide box, or a sensor pack so you remember the exact set you own.'},
    {'tag': 'RUN 03', 'title': 'Log a transfer', 'body': 'Move a kit from the prep room to Station B and leave a short note of why it moved.'},
    {'tag': 'RUN 04', 'title': 'Works offline', 'body': 'No account and no signal. The bench stays on this phone.'},
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
      backgroundColor: VisualTheme.graphite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('SKIP', style: GoogleFonts.ibmPlexMono(color: Colors.white38, letterSpacing: 1.4)),
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
                        Container(width: 36, height: 36, decoration: BoxDecoration(border: Border.all(color: VisualTheme.secondaryColor, width: 2))),
                        const SizedBox(height: 18),
                        Text(page['tag'] as String, style: GoogleFonts.ibmPlexMono(color: VisualTheme.secondaryColor, letterSpacing: 1.6, fontSize: 12)),
                        const SizedBox(height: 10),
                        Text(page['title'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, height: 1.05)),
                        const SizedBox(height: 14),
                        Text(page['body'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 16, height: 1.5, color: Colors.white70)),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('${_currentPage + 1}/5', style: GoogleFonts.ibmPlexMono(color: Colors.white38, fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN BENCH' : 'NEXT  ›', style: GoogleFonts.ibmPlexMono(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w600)),
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
