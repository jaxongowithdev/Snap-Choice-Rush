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
    {'icon': Icons.local_bar, 'title': 'Ember Rail', 'description': 'Stage every bar cart before guests arrive. Know which bottle lives on which rail.'},
    {'icon': Icons.liquor_outlined, 'title': 'Twelve kinds of stock', 'description': 'Spirits, amaro, bitters, citrus, glassware — file each pour by how you actually use it.'},
    {'icon': Icons.photo_camera_outlined, 'title': 'Snap the label', 'description': 'Photograph a bottle, a bitter, or a garnish so you remember the exact brand you own.'},
    {'icon': Icons.swap_horiz, 'title': 'Keep a pour log', 'description': 'Move a bottle from the cellar to the rail and keep a short note of why it moved.'},
    {'icon': Icons.wifi_off, 'title': 'Works at the cart', 'description': 'No account and no signal required. The catalog stays on this phone.'},
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('SKIP', style: GoogleFonts.sora(color: Colors.white54, letterSpacing: 1.4)),
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
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2414),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(page['icon'] as IconData, size: 44, color: VisualTheme.secondaryColor),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.45, color: Colors.white70),
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
                      margin: const EdgeInsets.only(right: 5),
                      width: _currentPage == i ? 22 : 8,
                      height: 4,
                      color: _currentPage == i ? VisualTheme.secondaryColor : Colors.white24,
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
                    child: Text(_currentPage == _pages.length - 1 ? 'Open the rail' : 'Next'),
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
