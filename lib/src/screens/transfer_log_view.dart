import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/storage_manager.dart';
import '../models/transfer_history_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';
import 'item_detail_view.dart';

class TransferLogView extends StatefulWidget {
  const TransferLogView({super.key});

  @override
  State<TransferLogView> createState() => _TransferLogViewState();
}

class _TransferLogViewState extends State<TransferLogView> {
  final _storage = StorageManager.instance;
  List<TransferHistoryModel>? _logs;
  final Map<int, String> _recipeNames = {};
  final Map<int, String> _workshopNames = {};
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
        if (!_recipeNames.containsKey(log.itemId)) {
          final recipe = await _storage.getItem(log.itemId);
          _recipeNames[log.itemId] = recipe?.name ?? 'Dropped recipe';
        }
        for (final id in [log.fromContainerId, log.toContainerId]) {
          if (!_workshopNames.containsKey(id)) {
            final w = await _storage.getContainer(id);
            _workshopNames[id] = w?.name ?? 'Closed workshop';
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading move log: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: PaperGrain(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 18, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Move log',
                          style: VisualTheme.display(28, color: VisualTheme.inkOf(context))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_logs == null || _logs!.isEmpty)
                        ? const EmptyDesk(
                            icon: Icons.swap_horiz_rounded,
                            tint: VisualTheme.inkBlue,
                            title: 'No moves yet',
                            body: 'Every time a recipe changes workshop, the move lands here with its note.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                              itemCount: _logs!.length,
                              itemBuilder: (_, i) {
                                final log = _logs![i];
                                final first = i == 0;
                                final last = i == _logs!.length - 1;
                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 1.5,
                                              height: 14,
                                              color: first
                                                  ? Colors.transparent
                                                  : VisualTheme.moss.withValues(alpha: 0.35),
                                            ),
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: VisualTheme.moss,
                                                border: Border.all(
                                                  color: dark
                                                      ? VisualTheme.night
                                                      : VisualTheme.paper,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: 1.5,
                                                color: last
                                                    ? Colors.transparent
                                                    : VisualTheme.moss.withValues(alpha: 0.35),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 12, left: 4),
                                          child: SheetCard(
                                            padding: const EdgeInsets.all(14),
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ItemDetailView(itemId: log.itemId),
                                                ),
                                              );
                                              _load();
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _recipeNames[log.itemId] ?? 'Recipe',
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: VisualTheme.heading(16,
                                                            color: VisualTheme.inkOf(context)),
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('MMM d').format(log.moveDate),
                                                      style: VisualTheme.tag(11,
                                                          color: VisualTheme.mutedOf(context)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: InkChip(
                                                        label: _workshopNames[
                                                                log.fromContainerId] ??
                                                            '—',
                                                        color: VisualTheme.mutedOf(context),
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                                      child: Icon(Icons.arrow_forward_rounded,
                                                          size: 14, color: VisualTheme.moss),
                                                    ),
                                                    Flexible(
                                                      child: InkChip(
                                                        label:
                                                            _workshopNames[log.toContainerId] ??
                                                                '—',
                                                        color: VisualTheme.moss,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if ((log.notes ?? '').isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  Text(log.notes!,
                                                      style: VisualTheme.body(13,
                                                          color: VisualTheme.mutedOf(context))),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
