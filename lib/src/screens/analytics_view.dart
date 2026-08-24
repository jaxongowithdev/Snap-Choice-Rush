import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../widgets/atlas_chrome.dart';

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
      appBar: AppBar(title: const Text('Survey')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                children: [
                  if (_stats != null)
                    Text('${_stats!['totalItems']} pins   ·   ${_stats!['totalContainers']} folios', style: GoogleFonts.fraunces(fontSize: 22)),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const LegendLabel(label: 'BY KIND'),
                    ..._categoryStats!.entries.map((e) => Text('${e.key}  ·  ${e.value}')),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const LegendLabel(label: 'BY ROOM'),
                    ..._roomStats!.entries.map((e) => Text('${e.key}  ·  ${e.value}')),
                  ],
                ],
              ),
            ),
    );
  }
}
