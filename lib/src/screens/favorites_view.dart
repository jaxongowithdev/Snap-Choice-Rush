import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
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
      appBar: AppBar(title: const Text('Pin')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.push_pin_outlined, size: 48, color: VisualTheme.secondaryColor),
                        const SizedBox(height: 12),
                        Text('Nothing on the desk', style: GoogleFonts.sourceSerif4(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Pin the readers and kits you keep in rotation this week.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (_, i) {
                      final item = _favoriteItems![i];
                      final tray = _containersCache[item.containerId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: VisualTheme.getCategoryColor(item.category).withValues(alpha: 0.16),
                              child: Icon(Icons.push_pin, color: VisualTheme.getCategoryColor(item.category), size: 18),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${item.category} · ${item.quantity}${tray != null ? '\n${tray.name} · ${tray.room}' : ''}'),
                            isThreeLine: tray != null,
                            trailing: IconButton(
                              key: ValueKey('favorite_toggle_${item.id}'),
                              icon: Icon(item.isFavorite ? Icons.push_pin : Icons.push_pin_outlined, color: item.isFavorite ? VisualTheme.secondaryColor : null),
                              onPressed: () async {
                                await _storage.updateItem(item.copyWith(isFavorite: !item.isFavorite));
                                _loadFavorites();
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                              _loadFavorites();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
