import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import 'container_detail_view.dart';
import 'item_form_view.dart';
import 'search_view.dart';
import 'container_form_view.dart';
import 'favorites_view.dart';
import 'item_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  Map<String, int> _subjects = {};
  List<ContainerModel>? _recentContainers;
  List<InventoryItemModel>? _pins;
  List<InventoryItemModel> _allItems = [];
  String? _subjectFilter;
  bool _isLoading = true;

  static const _subjectOrder = [
    'Readers', 'Workbooks', 'Flashcards', 'Manipulatives', 'Art', 'Science',
    'Maps', 'Stationery', 'Devices', 'Music', 'Games', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning circle';
    if (h < 16) return 'Lesson block';
    return 'Evening review';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final subjects = await _storage.getItemsByCategory();
      final recentMaps = await _storage.getRecentlyUpdatedContainers(limit: 5);
      final favorites = await _storage.getFavoriteItems();
      final items = await _storage.getAllItems();
      setState(() {
        _stats = stats;
        _subjects = subjects;
        _recentContainers = recentMaps.map(ContainerModel.fromMap).toList();
        _pins = favorites.take(8).toList();
        _allItems = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<InventoryItemModel> get _filteredItems {
    if (_subjectFilter == null) return const [];
    return _allItems.where((i) => i.category == _subjectFilter).take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PRIMER NEST', style: GoogleFonts.lexend(letterSpacing: 2.2, fontSize: 11, fontWeight: FontWeight.w700, color: VisualTheme.secondaryColor)),
            Text(_greeting, style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.push_pin_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesView())).then((_) => _loadData());
            },
          ),
          IconButton(
            key: const ValueKey('search_button'),
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: VisualTheme.primaryColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BEFORE CLASS', style: GoogleFonts.lexend(color: VisualTheme.accentColor, letterSpacing: 1.8, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                          (_stats?['totalItems'] ?? 0) == 0
                              ? 'The nest is empty. Stage a tray for Monday.'
                              : '${_stats!['totalItems']} pieces across ${_stats!['totalContainers']} lesson trays.',
                          style: GoogleFonts.sourceSerif4(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
                        ),
                        const SizedBox(height: 10),
                        Text('Readers, flashcards, science kits — file what you actually teach.', style: GoogleFonts.lexend(color: Colors.white70, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _chip('All', null),
                        ..._subjectOrder.where((s) => (_subjects[s] ?? 0) > 0 || _subjectFilter == s).map((s) => _chip('$s · ${_subjects[s] ?? 0}', s)),
                      ],
                    ),
                  ),
                  if (_subjectFilter != null) ...[
                    const SizedBox(height: 12),
                    if (_filteredItems.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text('No $_subjectFilter filed yet.', style: GoogleFonts.lexend(color: Colors.black54)),
                        ),
                      )
                    else
                      ..._filteredItems.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: VisualTheme.getCategoryColor(item.category).withValues(alpha: 0.16),
                                  child: Icon(Icons.menu_book_outlined, color: VisualTheme.getCategoryColor(item.category), size: 18),
                                ),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text('${item.category} · ${item.condition}'),
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                                  _loadData();
                                },
                              ),
                            ),
                          )),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _cta(key: const ValueKey('add_box_button'), label: 'New tray', onTap: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                        if (r == true) _loadData();
                      })),
                      const SizedBox(width: 10),
                      Expanded(child: _cta(key: const ValueKey('add_item_button'), label: 'File piece', clay: true, onTap: () async {
                        final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                        if (r == true) _loadData();
                      })),
                    ],
                  ),
                  if (_pins != null && _pins!.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Text('This week’s pin', style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Materials you keep on the teaching desk.', style: GoogleFonts.lexend(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 128,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pins!.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final item = _pins![i];
                          return InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                              _loadData();
                            },
                            child: Container(
                              width: 168,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0x22C4532C)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: 28, height: 4, color: VisualTheme.getCategoryColor(item.category)),
                                  const Spacer(),
                                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.sourceSerif4(fontSize: 16, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(item.category, style: GoogleFonts.lexend(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    Text('Last opened trays', style: GoogleFonts.sourceSerif4(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ..._recentContainers!.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: VisualTheme.sand,
                                child: Text(c.code.substring(0, 1), style: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w700, color: VisualTheme.primaryColor)),
                              ),
                              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${c.room} · ${c.shelf}'),
                              trailing: const Icon(Icons.arrow_forward, size: 18),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                                _loadData();
                              },
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: VisualTheme.accentColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Mark a workbook Worn when the binding gives out — restock before the next unit.', style: GoogleFonts.lexend(fontSize: 13, height: 1.45)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _subjectFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : VisualTheme.ink,
        ),
        onSelected: (_) => setState(() => _subjectFilter = value),
      ),
    );
  }

  Widget _cta({required Key key, required String label, required VoidCallback onTap, bool clay = false}) {
    return Material(
      color: clay ? VisualTheme.secondaryColor : VisualTheme.primaryColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
