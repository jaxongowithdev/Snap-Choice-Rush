import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'dashboard_view.dart';

class WelcomeView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const WelcomeView({super.key, required this.onSettingsChanged});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _seeding = false;

  static const _pages = [
    (
      'Kettleleaf',
      'A private tea journal on this phone. Caddies hold the families. Leaves hold the cup notes. Cupping writes the tasting — with no signal.',
      Icons.emoji_food_beverage_rounded,
      VisualTheme.clay,
    ),
    (
      'Caddies',
      'One caddy per family — morning greens, evening oolongs, a travel tin. Give it a code and a leaf target.',
      Icons.inventory_2_outlined,
      VisualTheme.moss,
    ),
    (
      'Leaves',
      'A leaf is a name, a steeping seed, a form (aroma, liquor, body…), and tags. Attach a photo of the dry leaf if you like.',
      Icons.eco_outlined,
      VisualTheme.inkBlue,
    ),
    (
      'Cupping on the phone',
      'The local note-writer fills the form from your seed. Rewrite, then grade the steep: Flat, First, Settled, Cellared.',
      Icons.local_cafe_outlined,
      VisualTheme.ochre,
    ),
    (
      'Yours alone',
      'No account, no cloud, no tracking. Caddies, leaves and cupping notes stay in this app’s storage and export as one file.',
      Icons.lock_outline_rounded,
      VisualTheme.sage,
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
    widget.onSettingsChanged();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardView(onSettingsChanged: widget.onSettingsChanged),
      ),
    );
  }

  Future<void> _seedStarterPack(StorageManager storage) async {
    final greenId = await storage.createContainer(ContainerModel(
      name: 'Morning greens',
      code: 'CAD-01',
      room: 'Green',
      shelf: 'First flush',
      capacity: 6,
    ));

    const greenLeaves = [
      (
        'Longjing, west lake',
        'Chestnut dry leaf. 80°C, 45 seconds, glass. Second steep sweeter.',
        'Aroma',
        'green, chestnut, morning'
      ),
      (
        'Sencha asatsuyu',
        'Steam-green, seaweed snap. Kyusu, 70°C, one minute. Pair with rice.',
        'Steep',
        'green, japan, steam'
      ),
      (
        'Gunpowder for travel',
        'Rolled pellets in a tin. Hotel kettle, lid on, three minutes. No milk.',
        'Note',
        'green, travel'
      ),
    ];

    for (final s in greenLeaves) {
      await storage.createItem(InventoryItemModel(
        containerId: greenId,
        name: s.$1,
        category: s.$3,
        notes: s.$2,
        condition: 'Dry',
        quantity: 0,
        keywords: s.$4,
        estimatedValue: VisualTheme.recallStrength('Dry') * 100,
      ));
    }

    final oolongId = await storage.createContainer(ContainerModel(
      name: 'Evening oolongs',
      code: 'CAD-02',
      room: 'Oolong',
      shelf: 'Roast',
      capacity: 5,
    ));

    const oolongLeaves = [
      (
        'Tieguanyin, light roast',
        'Orchid on the lid. Gaiwan, 95°C, flash rinse, 20 seconds.',
        'Ceremony',
        'oolong, orchid'
      ),
      (
        'Dong ding, charcoal',
        'Warm wood, thick liquor. Small cup. Stop before the roast shouts.',
        'Liquor',
        'oolong, roast'
      ),
    ];

    for (final s in oolongLeaves) {
      await storage.createItem(InventoryItemModel(
        containerId: oolongId,
        name: s.$1,
        category: s.$3,
        notes: s.$2,
        condition: 'Dry',
        quantity: 0,
        keywords: s.$4,
        estimatedValue: VisualTheme.recallStrength('Dry') * 100,
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
      body: PaperGrain(
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
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: p.$4,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p.$3, size: 46, color: Colors.white),
                          ),
                          const SizedBox(height: 28),
                          Text('PAGE ${i + 1} OF ${_pages.length}',
                              style: VisualTheme.tag(11, color: p.$4)),
                          const SizedBox(height: 10),
                          Text(p.$1,
                              style: VisualTheme.display(36, color: VisualTheme.inkOf(context))),
                          const SizedBox(height: 12),
                          Text(p.$2,
                              style: VisualTheme.body(16.5, color: VisualTheme.mutedOf(context))),
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
                        width: i == _page ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? _pages[_page].$4
                              : VisualTheme.mutedOf(context).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (last) ...[
                  FilledButton(
                    onPressed: _seeding ? null : () => _finish(seed: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: VisualTheme.moss,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: _seeding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Load the morning greens'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _seeding ? null : () => _finish(),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Start with a blank bench'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _pages[_page].$4,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
