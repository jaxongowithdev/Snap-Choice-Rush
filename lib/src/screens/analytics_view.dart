import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';
import '../widgets/binder_chrome.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  Map<String, int>? _categoryStats;
  Map<String, int>? _roomStats;
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
      final categories = await _storage.getItemsByCategory();
      final rooms = await _storage.getItemsByRoom();
      setState(() { _stats = stats; _categoryStats = categories; _roomStats = rooms; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Index')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                children: [
                  _overview(),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const Colophon(label: 'BY KIND'),
                    _chart(_categoryStats!, true),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const Colophon(label: 'BY DESK'),
                    _chart(_roomStats!, false),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _overview() {
    if (_stats == null) return const SizedBox.shrink();
    final spines = _stats!['totalContainers'] ?? 0;
    final items = _stats!['totalItems'] ?? 0;
    final empty = _stats!['emptyContainers'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TALLY', style: GoogleFonts.ibmPlexMono(color: VisualTheme.primaryColor, letterSpacing: 1.8, fontSize: 11)),
        const SizedBox(height: 12),
        Text('$spines spines   ·   $items drills   ·   ${spines - empty} live', style: GoogleFonts.libreBaskerville(fontSize: 18)),
      ],
    );
  }

  Widget _chart(Map<String, int> data, bool klass) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = _stats?['totalItems'] ?? 1;
    return Column(
      children: sorted.map((e) {
        final pct = (e.value / total * 100).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: Text(e.key, style: GoogleFonts.libreBaskerville())),
              Text('${e.value}  $pct%', style: GoogleFonts.ibmPlexMono(fontSize: 11, color: klass ? VisualTheme.getCategoryColor(e.key) : VisualTheme.primaryColor)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
