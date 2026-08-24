import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/stanza_chrome.dart';
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
  final Map<int, String> _folioNames = {};
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
          _itemNames[log.itemId] = item?.name ?? 'Unknown verse';
        }
        if (!_folioNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _folioNames[log.fromContainerId] = from?.name ?? 'Removed folio';
        }
        if (!_folioNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _folioNames[log.toContainerId] = to?.name ?? 'Removed folio';
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
      appBar: AppBar(title: const Text('Pass')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('still', style: GoogleFonts.spectral(fontSize: 32, fontStyle: FontStyle.italic, color: VisualTheme.primaryColor)),
                        Text('No passes yet', style: GoogleFonts.spectral(fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('When a verse changes folios, the pass lands here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 16, 28),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MMM d').format(log.moveDate);
                      return CoupletCard(
                        kind: when,
                        title: _itemNames[log.itemId] ?? 'Verse',
                        meta: '${_folioNames[log.fromContainerId]}  →  ${_folioNames[log.toContainerId]}${log.notes != null && log.notes!.isNotEmpty ? '  ·  ${log.notes}' : ''}',
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
