import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';
import 'item_detail_view.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final _storage = StorageManager.instance;
  List<InventoryItemModel>? _favoriteItems;
  Map<int, ContainerModel> _containersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _storage.getFavoriteItems();
      final containers = <int, ContainerModel>{};
      for (final item in favorites) {
        if (!containers.containsKey(item.containerId)) {
          final c = await _storage.getContainer(item.containerId);
          if (c != null) containers[item.containerId] = c;
        }
      }
      setState(() { _favoriteItems = favorites; _containersCache = containers; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Flags')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¶', style: GoogleFonts.libreBaskerville(fontSize: 42, color: VisualTheme.primaryColor)),
                        Text('No flags tonight', style: GoogleFonts.libreBaskerville(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Bookmark the papers and decks you will drill before bed.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 4, 20, 28),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (_, i) {
                      final item = _favoriteItems![i];
                      final spine = _containersCache[item.containerId];
                      return FlagLine(
                        accent: VisualTheme.getCategoryColor(item.category),
                        title: item.name,
                        subtitle: '${item.category}  ·  ${item.quantity}${spine != null ? '\n${spine.name}  ·  ${spine.room}' : ''}',
                        trailing: IconButton(
                          key: ValueKey('favorite_toggle_${item.id}'),
                          icon: Icon(item.isFavorite ? Icons.bookmark : Icons.bookmark_border, color: item.isFavorite ? VisualTheme.primaryColor : null),
                          onPressed: () async {
                            await _storage.updateItem(item.copyWith(isFavorite: !item.isFavorite));
                            _loadFavorites();
                          },
                        ),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                          _loadFavorites();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
