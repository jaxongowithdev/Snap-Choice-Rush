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
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('PIN')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.push_pin_outlined, color: VisualTheme.secondaryColor, size: 32),
                        const SizedBox(height: 10),
                        Text('No pins this period', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('Pin the trays you need before the next lab.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (_, i) {
                      final item = _favoriteItems![i];
                      final rack = _containersCache[item.containerId];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(width: 8, height: 8, color: VisualTheme.getCategoryColor(item.category)),
                        title: Text(item.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                        subtitle: Text('${item.category}  ·  ${item.quantity}${rack != null ? '\n${rack.name}  ·  ${rack.room}' : ''}', style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                        isThreeLine: rack != null,
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
                      );
                    },
                  ),
                ),
    );
  }
}
