import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
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
  final Map<int, String> _periodNames = {};
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
          _itemNames[log.itemId] = item?.name ?? 'Unknown piece';
        }
        if (!_periodNames.containsKey(log.fromContainerId)) {
          final from = await _storage.getContainer(log.fromContainerId);
          _periodNames[log.fromContainerId] = from?.name ?? 'Removed period';
        }
        if (!_periodNames.containsKey(log.toContainerId)) {
          final to = await _storage.getContainer(log.toContainerId);
          _periodNames[log.toContainerId] = to?.name ?? 'Removed period';
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
      appBar: AppBar(title: const Text('Shift')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs == null || _logs!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('—', style: GoogleFonts.syne(fontSize: 48, color: VisualTheme.secondaryColor)),
                        Text('No shifts yet', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('When a piece moves between periods, the line lands here.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    itemCount: _logs!.length,
                    itemBuilder: (_, i) {
                      final log = _logs![i];
                      final when = DateFormat('MMM d  ·  HH:mm').format(log.moveDate);
                      return InkWell(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailView(itemId: log.itemId)));
                          _load();
                        },
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 18,
                                child: Column(
                                  children: [
                                    Container(width: 8, height: 8, color: VisualTheme.secondaryColor),
                                    Expanded(child: Container(width: 1.4, color: Theme.of(context).dividerColor)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_itemNames[log.itemId] ?? 'Piece', style: GoogleFonts.syne(fontSize: 17, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 4),
                                      Text('${_periodNames[log.fromContainerId]}  →  ${_periodNames[log.toContainerId]}'),
                                      Text(when, style: GoogleFonts.manrope(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
                                      if (log.notes != null && log.notes!.isNotEmpty) Text(log.notes!, style: GoogleFonts.manrope(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
