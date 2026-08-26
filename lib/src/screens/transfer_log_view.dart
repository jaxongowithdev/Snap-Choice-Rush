import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/loci_chrome.dart';
import 'item_detail_view.dart';

class TransferLogView extends StatefulWidget {
  const TransferLogView({super.key});

  @override
  State<TransferLogView> createState() => _TransferLogViewState();
}

class _TransferLogViewState extends State<TransferLogView> {
  final _storage = StorageManager.instance;
  List<TransferHistoryModel>? _logs;
  final Map<int, String> _itemNames = {};
  final Map<int, String> _roomNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final logs = await _storage.getTransferHistory();
      for (final log in logs) {
        if (!_itemNames.containsKey(log.itemId)) {
          final item = await _storage.getItem(log.itemId);
          _itemNames[log.itemId] = item?.name ?? 'Unknown locus';
        }
        if (!_roomNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _roomNames[log.fromContainerId] = from?.name ?? 'Removed room';
        }
        if (!_roomNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _roomNames[log.toContainerId] = to?.name ?? 'Removed room';
        }
      }
      setState(() { _logs = logs; _isLoading = false; });
    } catch (e) {
      debugPrint('Error loading transfer log: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('LOG')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: VisualTheme.secondaryColor))
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('STILL', style: GoogleFonts.cinzel(fontSize: 12, letterSpacing: 3, color: VisualTheme.secondaryColor)),
                        Text('No transfers yet', style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        const Text('When a locus changes rooms, the plate lands here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MMM d').format(log.moveDate);
                      return StarPlate(
                        kind: when,
                        title: _itemNames[log.itemId] ?? 'Locus',
                        meta: '${_roomNames[log.fromContainerId]}  →  ${_roomNames[log.toContainerId]}${log.notes != null && log.notes!.isNotEmpty ? '  ·  ${log.notes}' : ''}',
                        accent: VisualTheme.secondaryColor,
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: log.itemId)));
                          _load();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
