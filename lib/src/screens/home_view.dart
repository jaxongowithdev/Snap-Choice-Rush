import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/bench_chrome.dart';
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
  List<ContainerModel> _racks = [];
  Map<int, int> _counts = {};
  List<InventoryItemModel> _all = [];
  List<InventoryItemModel> _pins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _storage.getStatistics();
      final racks = await _storage.getAllContainers(sortBy: 'updated');
      final counts = <int, int>{};
      for (final r in racks) {
        counts[r.id!] = await _storage.getItemCountInContainer(r.id!);
      }
      final items = await _storage.getAllItems();
      final pins = await _storage.getFavoriteItems();
      setState(() {
        _stats = stats;
        _racks = racks;
        _counts = counts;
        _all = items;
        _pins = pins.take(8).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<InventoryItemModel> _lane(String condition) =>
      _all.where((i) => i.condition == condition).take(8).toList();

  @override
  Widget build(BuildContext context) {
    final stamp = DateFormat('yyyy.MM.dd  HH:mm').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(stamp),
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
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                children: [
                  Text('BEAKER BENCH', style: GoogleFonts.ibmPlexMono(fontSize: 11, letterSpacing: 2, color: VisualTheme.primaryColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Station readout', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, height: 1.05)),
                  const SizedBox(height: 6),
                  Text(
                    (_stats?['totalItems'] ?? 0) == 0
                        ? 'No kits on the bench. Add a rack before first period.'
                        : 'n=${_stats!['totalItems']}  racks=${_stats!['totalContainers']}  live=${(_stats!['totalContainers'] ?? 0) - (_stats!['emptyContainers'] ?? 0)}',
                    style: GoogleFonts.ibmPlexMono(fontSize: 12),
                  ),
                  const SpecLabel(label: 'RACK GRID'),
                  if (_racks.isEmpty)
                    Text('Empty bench.\nStation A glassware. Prep room sensors. Safety crate.', style: GoogleFonts.spaceGrotesk(height: 1.45))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _racks.take(6).length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.15, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemBuilder: (_, i) {
                        final c = _racks[i];
                        final count = _counts[c.id] ?? 0;
                        return WellTile(
                          code: c.code,
                          title: c.name,
                          meta: '$count / ${c.capacity} wells',
                          fill: c.capacity > 0 ? count / c.capacity : 0,
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
                            _loadData();
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const ValueKey('add_box_button'),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), side: const BorderSide(color: VisualTheme.primaryColor)),
                          onPressed: () async {
                            final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                            if (r == true) _loadData();
                          },
                          child: Text('NEW RACK', style: GoogleFonts.ibmPlexMono(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('add_item_button'),
                          onPressed: () async {
                            final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                            if (r == true) _loadData();
                          },
                          child: const Text('FILE SET'),
                        ),
                      ),
                    ],
                  ),
                  if (_all.isNotEmpty) ...[
                    const SpecLabel(label: 'LANES  ·  CLEAN / IN USE / DIRTY'),
                    SizedBox(
                      height: 86,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final cond in const ['Clean', 'In use', 'Dirty'])
                            ..._lane(cond).map((item) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: LaneChip(
                                    color: VisualTheme.getConditionColor(cond),
                                    title: item.name,
                                    subtitle: '$cond  ·  ${item.category}',
                                    onTap: () async {
                                      await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                                      _loadData();
                                    },
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ],
                  if (_pins.isNotEmpty) ...[
                    const SpecLabel(label: 'PINNED FOR THE PERIOD'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pins.map((item) => ActionChip(
                            label: Text(item.name, style: GoogleFonts.ibmPlexMono(fontSize: 11)),
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)));
                              _loadData();
                            },
                          )).toList(),
                    ),
                  ],
                  const SpecLabel(label: 'NOTE'),
                  Text('Mark a tray Dirty when the period ends — wash before tomorrow’s first lab.', style: GoogleFonts.spaceGrotesk(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
    );
  }
}
