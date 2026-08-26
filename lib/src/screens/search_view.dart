import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'item_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _storage = StorageManager.instance;
  final _controller = TextEditingController();
  List<InventoryItemModel>? _results;
  Map<int, ContainerModel> _missions = {};
  bool _isSearching = false;

  static const _suggestions = ['planet', 'moon', 'orbit', 'quiz', 'week 1', 'peg'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _storage.searchItems(query);
      final missions = <int, ContainerModel>{};
      for (final cue in results) {
        if (!missions.containsKey(cue.containerId)) {
          final m = await _storage.getContainer(cue.containerId);
          if (m != null) missions[cue.containerId] = m;
        }
      }
      if (!mounted) return;
      setState(() {
        _results = results;
        _missions = missions;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: StarDust(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 18, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: VisualTheme.surfaceOf(context),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: VisualTheme.softShadow(dark),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded,
                                size: 20, color: VisualTheme.mutedOf(context)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                key: const ValueKey('search_field'),
                                controller: _controller,
                                autofocus: true,
                                style: VisualTheme.body(15,
                                    color: VisualTheme.inkOf(context), w: FontWeight.w600),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'cue, anchor, tag…',
                                  hintStyle: VisualTheme.body(15,
                                      color: VisualTheme.mutedOf(context)),
                                ),
                                onChanged: _search,
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _search('');
                                },
                                child: Icon(Icons.close_rounded,
                                    size: 20, color: VisualTheme.mutedOf(context)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_isSearching) return const Center(child: CircularProgressIndicator());

    if (_controller.text.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
        children: [
          Text('Try one of these',
              style: VisualTheme.heading(17,
                  color: VisualTheme.inkOf(context), w: FontWeight.w700)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map((s) => GestureDetector(
                      onTap: () {
                        _controller.text = s;
                        _search(s);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: VisualTheme.nova.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s,
                            style: VisualTheme.heading(13.5,
                                color: VisualTheme.nova, w: FontWeight.w700)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 30),
          BentoTile(
            fill: VisualTheme.veilOf(context),
            child: Text(
              'Search looks inside cue fronts, anchors, tags and cue types.',
              style: VisualTheme.body(14, color: VisualTheme.mutedOf(context)),
            ),
          ),
        ],
      );
    }

    if (_results == null || _results!.isEmpty) {
      return const EmptyOrbit(
        icon: Icons.travel_explore_rounded,
        tint: VisualTheme.plum,
        title: 'Nothing matched',
        body: 'Try a shorter word, or search by cue type instead.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
      itemCount: _results!.length,
      itemBuilder: (_, i) {
        final cue = _results![i];
        final mission = _missions[cue.containerId];
        return CueTile(
          kind: cue.category,
          title: cue.name,
          meta: mission?.name ?? cue.category,
          recall: cue.condition,
          accent: VisualTheme.getCategoryColor(cue.category),
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ItemDetailView(itemId: cue.id!)))
                .then((_) => _search(_controller.text));
          },
        );
      },
    );
  }
}
