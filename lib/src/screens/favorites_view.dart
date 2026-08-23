import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/slate_chrome.dart';
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
      appBar: AppBar(title: const Text('Star')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('★', style: GoogleFonts.syne(fontSize: 42, color: VisualTheme.accentColor)),
                        const SizedBox(height: 8),
                        Text('Nothing starred', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Star the stacks you need before the next bell.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (_, i) {
                      final item = _favoriteItems![i];
                      final period = _containersCache[item.containerId];
                      return MaterialLine(
                        accent: VisualTheme.getCategoryColor(item.category),
                        title: item.name,
                        subtitle: '${item.category}  ·  ${item.quantity}${period != null ? '\n${period.name}  ·  ${period.room}' : ''}',
                        trailing: IconButton(
                          key: ValueKey('favorite_toggle_${item.id}'),
                          icon: Icon(item.isFavorite ? Icons.star : Icons.star_outline, color: item.isFavorite ? VisualTheme.accentColor : null),
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
