import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';

class ConfigView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const ConfigView({super.key, required this.onSettingsChanged});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _storage = StorageManager.instance;
  UserPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await _storage.getPreferences();
      if (mounted) setState(() => _prefs = prefs);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _setTheme(String theme) async {
    if (_prefs == null) return;
    final updated = _prefs!.copyWith(theme: theme);
    AppAppearance.apply(theme);
    setState(() => _prefs = updated);
    await _storage.updatePreferences(updated);
    widget.onSettingsChanged();
  }

  Future<void> _export() async {
    try {
      final data = await _storage.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(jsonString)),
            mimeType: 'application/json',
            name: 'quietforge_${DateTime.now().millisecondsSinceEpoch}.json',
          )
        ],
        text: 'Quietforge backup',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup exported')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not export: $e')));
      }
    }
  }

  Future<void> _import() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore from a backup?'),
        content: const Text('Every workshop and recipe on this phone is replaced by the file you pick.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
      final data =
          jsonDecode(utf8.decode(result.files.first.bytes!)) as Map<String, dynamic>;
      await _storage.importData(data);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Backup restored')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not restore: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _prefs?.theme ?? 'system';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
          children: [
            Text('Atelier',
                style: VisualTheme.display(32, color: VisualTheme.inkOf(context))),
            const SizedBox(height: 4),
            Text('Everything here stays on this phone.',
                style: VisualTheme.body(14.5, color: VisualTheme.mutedOf(context))),
            const SizedBox(height: 20),

            SheetCard(
              fill: VisualTheme.clay,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quietforge',
                            style: VisualTheme.display(22, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text('Version 1.0.0 · on-device',
                            style: VisualTheme.body(13,
                                color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const DeskHead(title: 'Appearance'),
            SheetCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final e in const [
                    ('light', 'Paper daylight', Icons.light_mode_outlined),
                    ('dark', 'Lamp light', Icons.dark_mode_outlined),
                    ('system', 'Match this phone', Icons.smartphone_outlined),
                  ])
                    _Row(
                      icon: e.$3,
                      label: e.$2,
                      tint: VisualTheme.clay,
                      trailing: Icon(
                        theme == e.$1
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: theme == e.$1
                            ? VisualTheme.clay
                            : VisualTheme.mutedOf(context).withValues(alpha: 0.5),
                      ),
                      onTap: () => _setTheme(e.$1),
                    ),
                ],
              ),
            ),

            const DeskHead(title: 'Your data'),
            SheetCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _Row(
                    key: const ValueKey('backup_button'),
                    icon: Icons.ios_share_rounded,
                    label: 'Export a backup',
                    sub: 'One JSON file with every workshop and recipe',
                    tint: VisualTheme.moss,
                    onTap: _export,
                  ),
                  _Row(
                    key: const ValueKey('import_button'),
                    icon: Icons.download_rounded,
                    label: 'Restore a backup',
                    sub: 'Replaces what is on this phone',
                    tint: VisualTheme.ochre,
                    onTap: _import,
                  ),
                ],
              ),
            ),

            const DeskHead(title: 'How Spark grades a draft'),
            SheetCard(
              fill: VisualTheme.veilOf(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in const [
                    ('Seed', 'Filed, not yet composed.'),
                    ('Rough', 'Usable bones. Needs a pass.'),
                    ('Tuned', 'You would send it after one check.'),
                    ('Ready', 'You would send it as written.'),
                    ('Shelved', 'Not this. Back of the queue.'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 74,
                            child: InkChip(
                                label: line.$1,
                                color: VisualTheme.getConditionColor(line.$1)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(line.$2,
                                style: VisualTheme.body(13.5,
                                    color: VisualTheme.mutedOf(context))),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const DeskHead(title: 'Privacy'),
            SheetCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No account. No tracking. No network calls.',
                      style: VisualTheme.heading(16, color: VisualTheme.inkOf(context))),
                  const SizedBox(height: 6),
                  Text(
                    'Workshops, recipes, pictures and spark history live in this app’s own storage. Camera and photo library are only used when you attach a mood picture to a recipe. Drafts are composed on the phone from your seed, form and tags — not sent to a server.',
                    style: VisualTheme.body(13.5, color: VisualTheme.mutedOf(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Color tint;
  final Widget? trailing;
  final VoidCallback onTap;
  const _Row({
    super.key,
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
    this.sub,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VisualTheme.rL),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: tint),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: VisualTheme.heading(15.5, color: VisualTheme.inkOf(context))),
                  if (sub != null)
                    Text(sub!,
                        style: VisualTheme.body(12.5, color: VisualTheme.mutedOf(context))),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded, color: VisualTheme.mutedOf(context)),
          ],
        ),
      ),
    );
  }
}
