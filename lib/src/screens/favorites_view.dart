import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'item_detail_view.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final _storage = StorageManager.instance;
  List<InventoryItemModel>? _hearth;
  Map<int, ContainerModel> _workshops = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final hearth = await _storage.getFavoriteItems();
      final workshops = <int, ContainerModel>{};
      for (final recipe in hearth) {
        if (!workshops.containsKey(recipe.containerId)) {
          final w = await _storage.getContainer(recipe.containerId);
          if (w != null) workshops[recipe.containerId] = w;
        }
      }
      if (!mounted) return;
      setState(() {
        _hearth = hearth;
        _workshops = workshops;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading hearth: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperGrain(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Hearth',
                          style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
                    ),
                    if (_hearth != null)
                      InkChip(label: '${_hearth!.length} pinned', color: VisualTheme.wine),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_hearth == null || _hearth!.isEmpty)
                        ? const EmptyDesk(
                            icon: Icons.favorite_border_rounded,
                            tint: VisualTheme.wine,
                            title: 'Hearth is empty',
                            body:
                                'Pin the recipes you want in tonight’s spark — they queue up in Spark.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                              itemCount: _hearth!.length,
                              itemBuilder: (_, i) {
                                final recipe = _hearth![i];
                                final workshop = _workshops[recipe.containerId];
                                return RecipeRow(
                                  kind: recipe.category,
                                  title: recipe.name,
                                  meta: workshop == null
                                      ? recipe.category
                                      : '${workshop.name} · ${recipe.quantity} sparks',
                                  recall: recipe.condition,
                                  accent: VisualTheme.getCategoryColor(recipe.category),
                                  trailing: IconButton(
                                    key: ValueKey('favorite_toggle_${recipe.id}'),
                                    icon: const Icon(Icons.favorite_rounded,
                                        color: VisualTheme.wine),
                                    onPressed: () async {
                                      await _storage
                                          .updateItem(recipe.copyWith(isFavorite: false));
                                      _load();
                                    },
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ItemDetailView(itemId: recipe.id!)));
                                    _load();
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
