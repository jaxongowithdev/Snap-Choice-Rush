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

  static const _papers = [
    Color(0xFF4A90C8),
    Color(0xFFE24B3D),
    Color(0xFFF0C020),
    Color(0xFF7B5EA7),
    Color(0xFF5AAB5A),
  ];

  final _pages = [
    {'circle': '1', 'title': 'Cubby Wall', 'body': 'A classroom journal for the morning. One cubby per learning center. Know which tote sits in which bin before circle time.'},
    {'circle': '2', 'title': 'Twelve centers', 'body': 'Blocks, art, dramatic play, sensory — file each kit the way your room actually runs.'},
    {'circle': '3', 'title': 'Snap the tote', 'body': 'Photograph a bin, a name tag, or a morning kit so you remember the exact tub on the wall.'},
    {'circle': '4', 'title': 'Move a kit', 'body': 'Shift a tote from the art cubby to the quiet shelf and leave a short note of why it moved.'},
    {'circle': '5', 'title': 'Works offline', 'body': 'No account and no signal. The classroom catalog stays on this phone.'},
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
    final paper = _papers[_currentPage];
    final ink = _currentPage == 2 ? VisualTheme.ink : VisualTheme.label;
    return Scaffold(
      backgroundColor: paper,
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
                  child: Text('SKIP', style: GoogleFonts.fredoka(color: ink.withValues(alpha: 0.45), letterSpacing: 1.4)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: VisualTheme.label, borderRadius: BorderRadius.circular(6)),
                          child: Text('CIRCLE ${page['circle']}', style: GoogleFonts.fredoka(fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.w600, color: VisualTheme.ink)),
                        ),
                        const SizedBox(height: 18),
                        Text(page['title'] as String, style: GoogleFonts.fredoka(fontSize: 40, fontWeight: FontWeight.w600, color: ink, height: 1.05)),
                        const SizedBox(height: 16),
                        Text(page['body'] as String, style: GoogleFonts.literata(fontSize: 17, height: 1.5, color: ink.withValues(alpha: 0.88))),
                        const Spacer(),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Text('circle ${_currentPage + 1} of 5', style: GoogleFonts.fredoka(color: ink.withValues(alpha: 0.5))),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'OPEN THE ROOM' : 'NEXT CIRCLE →', style: GoogleFonts.fredoka(color: ink, fontWeight: FontWeight.w600)),
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
