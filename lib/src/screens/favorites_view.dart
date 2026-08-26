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
  List<InventoryItemModel>? _deck;
  Map<int, ContainerModel> _missions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final deck = await _storage.getFavoriteItems();
      final missions = <int, ContainerModel>{};
      for (final cue in deck) {
        if (!missions.containsKey(cue.containerId)) {
          final m = await _storage.getContainer(cue.containerId);
          if (m != null) missions[cue.containerId] = m;
        }
      }
      if (!mounted) return;
      setState(() {
        _deck = deck;
        _missions = missions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading drill deck: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarDust(
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
                      child: Text('Drill deck',
                          style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
                    ),
                    if (_deck != null)
                      TinyPill(label: '${_deck!.length} starred', color: VisualTheme.sun),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_deck == null || _deck!.isEmpty)
                        ? const EmptyOrbit(
                            icon: Icons.star_rounded,
                            tint: VisualTheme.sun,
                            title: 'Deck is empty',
                            body:
                                'Star the cues you want in tonight’s run — they queue up in the drill room.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                              itemCount: _deck!.length,
                              itemBuilder: (_, i) {
                                final cue = _deck![i];
                                final mission = _missions[cue.containerId];
                                return CueTile(
                                  kind: cue.category,
                                  title: cue.name,
                                  meta: mission == null
                                      ? cue.category
                                      : '${mission.name} · ${cue.quantity} reps',
                                  recall: cue.condition,
                                  accent: VisualTheme.getCategoryColor(cue.category),
                                  trailing: IconButton(
                                    key: ValueKey('favorite_toggle_${cue.id}'),
                                    icon: const Icon(Icons.star_rounded,
                                        color: VisualTheme.sun),
                                    onPressed: () async {
                                      await _storage
                                          .updateItem(cue.copyWith(isFavorite: false));
                                      _load();
                                    },
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ItemDetailView(itemId: cue.id!)));
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
