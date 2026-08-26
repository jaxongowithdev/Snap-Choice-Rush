import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'dashboard_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _seeding = false;

  static const _pages = [
    (
      'Orbit Recall',
      'A memory-training deck for space class. Missions hold the facts, cues hold the pictures that make them stick.',
      Icons.bolt_rounded,
      VisualTheme.nova,
    ),
    (
      'Missions',
      'One mission per topic — the eight planets, Jupiter’s moons, the Apollo timeline. Set a target and fill it.',
      Icons.rocket_launch_rounded,
      VisualTheme.sky,
    ),
    (
      'Cues and anchors',
      'The front is what you get asked. The anchor is the strange picture that answers it. Add a photo if it helps.',
      Icons.style_rounded,
      VisualTheme.rose,
    ),
    (
      'Drill, then grade',
      'The drill room queues your weakest cues first. Flip, answer out loud, and grade yourself honestly.',
      Icons.psychology_rounded,
      VisualTheme.flare,
    ),
    (
      'Yours alone',
      'No account, no signal, no tracking. Everything lives on this phone and exports as one file whenever you want.',
      Icons.lock_rounded,
      VisualTheme.mint,
    ),
  ];

  Future<void> _finish({bool seed = false}) async {
    setState(() => _seeding = seed);
    final storage = StorageManager.instance;
    try {
      if (seed) await _seedStarterPack(storage);
      final prefs = await storage.getPreferences();
      await storage.updatePreferences(prefs.copyWith(showOnboarding: false));
    } catch (e) {
      debugPrint('Onboarding finish error: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardView(onSettingsChanged: () {})),
    );
  }

  Future<void> _seedStarterPack(StorageManager storage) async {
    final missionId = await storage.createContainer(ContainerModel(
      name: 'The Eight Planets',
      code: 'MSN-01',
      room: 'Planets',
      shelf: 'Launch',
      capacity: 8,
    ));

    const seeds = [
      ('Closest planet to the Sun', 'Mercury — a silver thermometer melting on my doorstep.', 'Image'),
      ('Hottest planet in the solar system', 'Venus — a greenhouse full of steam where the porch should be.', 'Story'),
      ('The planet we live on', 'Earth — a blue marble spinning in the hallway mirror.', 'Peg'),
      ('The rusty red planet', 'Mars — a rusted red bicycle leaning by the stairs.', 'Image'),
      ('Largest planet, with the Great Red Spot', 'Jupiter — a giant striped beach ball with one angry eye.', 'Image'),
      ('The ringed planet', 'Saturn — a hula hoop resting on the kitchen table.', 'Journey'),
      ('The planet tipped on its side', 'Uranus — a barrel rolling sideways down the corridor.', 'Story'),
      ('Farthest planet from the Sun', 'Neptune — a deep blue ice bucket at the very end of the hall.', 'Journey'),
    ];

    for (final s in seeds) {
      await storage.createItem(InventoryItemModel(
        containerId: missionId,
        name: s.$1,
        category: s.$3,
        notes: s.$2,
        condition: 'Fresh',
        quantity: 0,
        keywords: 'planets, starter',
        estimatedValue: VisualTheme.recallStrength('Fresh') * 100,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;

    return Scaffold(
      body: StarDust(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _seeding ? null : () => _finish(),
                    child: const Text('Skip'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: p.$4,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: p.$4.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Icon(p.$3, size: 56, color: Colors.white),
                          ),
                          const SizedBox(height: 34),
                          Text('STEP ${i + 1} OF ${_pages.length}',
                              style: VisualTheme.tag(11, color: p.$4)),
                          const SizedBox(height: 10),
                          Text(p.$1,
                              style: VisualTheme.display(38,
                                  color: VisualTheme.inkOf(context))),
                          const SizedBox(height: 14),
                          Text(p.$2,
                              style: VisualTheme.body(16,
                                  color: VisualTheme.mutedOf(context))),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _page ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? _pages[_page].$4
                              : VisualTheme.mutedOf(context).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (last) ...[
                  FilledButton(
                    onPressed: _seeding ? null : () => _finish(seed: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: VisualTheme.mint,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: _seeding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Start with the planets pack'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _seeding ? null : () => _finish(),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    child: const Text('Start empty'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _pages[_page].$4,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
