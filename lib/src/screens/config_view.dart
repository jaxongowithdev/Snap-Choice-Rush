import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';

class ConfigView extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  const ConfigView({super.key, required this.onSettingsChanged});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _storage = StorageManager.instance;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _storage.getPreferences();
      setState(() => _preferences = prefs);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _updateTheme(String theme) async {
    if (_preferences == null) return;
    final updated = _preferences!.copyWith(theme: theme);
    await _storage.updatePreferences(updated);
    setState(() => _preferences = updated);
    widget.onSettingsChanged();
  }

  Future<void> _exportData() async {
    try {
      final data = await _storage.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await Share.shareXFiles(
        [XFile.fromData(Uint8List.fromList(jsonString.codeUnits), mimeType: 'application/json', name: 'nib_ledger_${DateTime.now().millisecondsSinceEpoch}.json')],
        text: 'Nib Ledger catalog',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalog exported')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not export: $e')));
    }
  }

  Future<void> _importData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore a catalog?'),
        content: const Text('The current wells will be replaced by the file you pick.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
      final data = jsonDecode(String.fromCharCodes(result.files.first.bytes!)) as Map<String, dynamic>;
      await _storage.importData(data);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catalog restored')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not restore: $e')));
    }
  }

  String _themeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Paper';
      case 'dark':
        return 'Night ink';
      default:
        return 'Match the phone';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NIB LEDGER', style: GoogleFonts.outfit(color: VisualTheme.accentColor, letterSpacing: 1.8, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('A private ink list. Nothing leaves this phone.', style: GoogleFonts.literata(color: VisualTheme.cream, fontSize: 24, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Look'),
            subtitle: Text(_themeLabel(_preferences?.theme ?? 'system')),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Case light'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final e in const [('light', 'Paper'), ('dark', 'Night ink'), ('system', 'Match the phone')])
                      RadioListTile<String>(
                        title: Text(e.$2),
                        value: e.$1,
                        groupValue: _preferences?.theme ?? 'system',
                        onChanged: (v) { if (v != null) { _updateTheme(v); Navigator.pop(context); } },
                      ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(key: const ValueKey('backup_button'), leading: const Icon(Icons.ios_share), title: const Text('Export catalog'), subtitle: const Text('Share a JSON snapshot'), onTap: _exportData),
          ListTile(key: const ValueKey('import_button'), leading: const Icon(Icons.file_open_outlined), title: const Text('Restore catalog'), subtitle: const Text('Replace from a JSON file'), onTap: _importData),
          const ListTile(leading: Icon(Icons.info_outline), title: Text('Version 1.0.0'), subtitle: Text('Offline fountain-pen inventory')),
          const ListTile(leading: Icon(Icons.lock_outline), title: Text('Privacy'), subtitle: Text('No account. No tracking. Local only.')),
        ],
      ),
    );
  }
}
