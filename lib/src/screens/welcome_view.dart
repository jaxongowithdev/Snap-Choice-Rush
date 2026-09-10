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
      'Quietforge',
      'A private writing studio that lives on this phone. Workshops hold the jobs. Recipes hold the brief. Spark composes the draft — with no signal.',
      Icons.edit_note_rounded,
      VisualTheme.clay,
    ),
    (
      'Workshops',
      'One workshop per craft — shop windows, classroom openers, a weekly letter. Give it a code and a recipe target.',
      Icons.folder_open_rounded,
      VisualTheme.moss,
    ),
    (
      'Recipes',
      'A recipe is a title, a seed, a form, and optional tags. Attach a mood photo if it helps the voice.',
      Icons.notes_rounded,
      VisualTheme.inkBlue,
    ),
    (
      'Spark on the phone',
      'The local composer fills the form from your seed, then you rewrite: tighten, expand, warmer, formal, shorter. Grade what to keep.',
      Icons.local_fire_department_rounded,
      VisualTheme.ochre,
    ),
    (
      'Yours alone',
      'No account, no cloud, no tracking. Workshops, recipes and drafts stay in this app’s storage and export as one file.',
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
    final shopId = await storage.createContainer(ContainerModel(
      name: 'Shop window copy',
      code: 'WKS-01',
      room: 'Product',
      shelf: 'Drafting',
      capacity: 6,
    ));

    const shopSeeds = [
      (
        'Saturday market opener',
        'Heirloom tomatoes, still warm. Neighbourhood stall, cash or tap. We close at two.',
        'Caption',
        'shop, warm, Saturday'
      ),
      (
        'Welcome note for first-time buyers',
        'They found us from a friend. Thank them. One care tip for the first week. No coupon dump.',
        'Letter',
        'buyer, warm'
      ),
      (
        'One-line product hook',
        'A linen apron that actually lasts the dinner rush. Made in small batches.',
        'Hook',
        'product, bold'
      ),
      (
        'Care card inside the box',
        'Wash cold, hang dry, linen softens. If a stitch opens, send a photo and we mend it.',
        'Product',
        'product, calm'
      ),
    ];

    for (final s in shopSeeds) {
      await storage.createItem(InventoryItemModel(
        containerId: shopId,
        name: s.$1,
        category: s.$3,
        notes: s.$2,
        condition: 'Seed',
        quantity: 0,
        keywords: s.$4,
        estimatedValue: VisualTheme.recallStrength('Seed') * 100,
      ));
    }

    final classId = await storage.createContainer(ContainerModel(
      name: 'Classroom openers',
      code: 'WKS-02',
      room: 'Classroom',
      shelf: 'Brief',
      capacity: 5,
    ));

    const classSeeds = [
      (
        'Five-minute freewrite',
        'Grade 7. Topic: a place that smells like rain. Share one sentence, not the whole page.',
        'Lesson',
        'student, calm, class'
      ),
      (
        'Parent note after the field trip',
        'Museum was loud and good. Ask what object they would steal for the classroom shelf.',
        'Letter',
        'parent, warm'
      ),
    ];

    for (final s in classSeeds) {
      await storage.createItem(InventoryItemModel(
        containerId: classId,
        name: s.$1,
        category: s.$3,
        notes: s.$2,
        condition: 'Seed',
        quantity: 0,
        keywords: s.$4,
        estimatedValue: VisualTheme.recallStrength('Seed') * 100,
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
                        : const Text('Load the starter workshops'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _seeding ? null : () => _finish(),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Start with a blank desk'),
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
