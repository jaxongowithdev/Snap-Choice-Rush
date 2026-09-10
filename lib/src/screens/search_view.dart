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
  Map<int, ContainerModel> _workshops = {};
  bool _isSearching = false;

  static const _suggestions = ['caption', 'letter', 'warm', 'class', 'hook', 'shop'];

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
      final workshops = <int, ContainerModel>{};
      for (final recipe in results) {
        if (!workshops.containsKey(recipe.containerId)) {
          final w = await _storage.getContainer(recipe.containerId);
          if (w != null) workshops[recipe.containerId] = w;
        }
      }
      if (!mounted) return;
      setState(() {
        _results = results;
        _workshops = workshops;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrain(
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
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: VisualTheme.surfaceOf(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0x227AB8A8)
                                : const Color(0x1A1C1916),
                          ),
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
                                    color: VisualTheme.inkOf(context), w: FontWeight.w500),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: 'title, seed, tag, form…',
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
              style: VisualTheme.heading(17, color: VisualTheme.inkOf(context))),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: VisualTheme.clay.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s,
                            style: VisualTheme.heading(13.5, color: VisualTheme.clay)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),
          SheetCard(
            fill: VisualTheme.veilOf(context),
            child: Text(
              'Search looks inside titles, seeds, tags and forms.',
              style: VisualTheme.body(14, color: VisualTheme.mutedOf(context)),
            ),
          ),
        ],
      );
    }

    if (_results == null || _results!.isEmpty) {
      return const EmptyDesk(
        icon: Icons.search_off_rounded,
        tint: VisualTheme.inkBlue,
        title: 'Nothing matched',
        body: 'Try a shorter word, or search by form instead.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
      itemCount: _results!.length,
      itemBuilder: (_, i) {
        final recipe = _results![i];
        final workshop = _workshops[recipe.containerId];
        return RecipeRow(
          kind: recipe.category,
          title: recipe.name,
          meta: workshop?.name ?? recipe.category,
          recall: recipe.condition,
          accent: VisualTheme.getCategoryColor(recipe.category),
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ItemDetailView(itemId: recipe.id!)))
                .then((_) => _search(_controller.text));
          },
        );
      },
    );
  }
}
