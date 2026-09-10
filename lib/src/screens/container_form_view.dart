import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import '../widgets/cosmo_chrome.dart';

class ContainerFormView extends StatefulWidget {
  final ContainerModel? container;
  const ContainerFormView({super.key, this.container});

  @override
  State<ContainerFormView> createState() => _ContainerFormViewState();
}

class _ContainerFormViewState extends State<ContainerFormView> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageManager.instance;
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _capacityController;
  String _craft = VisualTheme.tracks.first;
  String _stage = 'Brief';

  static const _stages = ['Brief', 'Drafting', 'Revising', 'Polished', 'Archived'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container?.name);
    _codeController = TextEditingController(text: widget.container?.code);
    _capacityController =
        TextEditingController(text: widget.container?.capacity.toString() ?? '8');
    final room = widget.container?.room;
    _craft = (room != null && VisualTheme.tracks.contains(room))
        ? room
        : VisualTheme.tracks.first;
    final shelf = widget.container?.shelf;
    _stage = (shelf != null && _stages.contains(shelf)) ? shelf : 'Brief';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final workshop = ContainerModel(
      id: widget.container?.id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      room: _craft,
      shelf: _stage,
      capacity: int.parse(_capacityController.text.trim()),
      createdAt: widget.container?.createdAt,
    );
    try {
      if (widget.container == null) {
        await _storage.createContainer(workshop);
      } else {
        await _storage.updateContainer(workshop);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Could not save workshop: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That workshop code is already in use.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.container != null;
    return Scaffold(
      body: PaperGrain(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(isEditing ? 'Edit workshop' : 'New workshop',
                    style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
                const SizedBox(height: 6),
                Text('Name the craft, give it a code, set how many recipes you are aiming for.',
                    style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                const SizedBox(height: 22),
                SheetCard(
                  child: Column(
                    children: [
                      TextFormField(
                        key: const ValueKey('name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Workshop name',
                          hintText: 'e.g. Shop window copy',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name this workshop' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('code_field'),
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Workshop code',
                          hintText: 'e.g. WKS-04',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Add a short code' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('capacity_field'),
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Target recipe count'),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          return (n == null || n <= 0) ? 'Use a positive number' : null;
                        },
                      ),
                    ],
                  ),
                ),
                const DeskHead(title: 'Craft'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VisualTheme.tracks
                      .map((t) => _Choice(
                            label: t,
                            icon: VisualTheme.trackIcon(t),
                            selected: _craft == t,
                            onTap: () => setState(() => _craft = t),
                          ))
                      .toList(),
                ),
                const DeskHead(title: 'Stage'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _stages
                      .map((s) => _Choice(
                            label: s,
                            selected: _stage == s,
                            onTap: () => setState(() => _stage = s),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  key: const ValueKey('save_button'),
                  onPressed: _save,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  child: Text(isEditing ? 'Save workshop' : 'Open workshop'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? VisualTheme.clay : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(6),
          border: selected ? null : Border.all(color: const Color(0x1A1C1916)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14, color: selected ? Colors.white : VisualTheme.mutedOf(context)),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: VisualTheme.heading(13.5,
                    color: selected ? Colors.white : VisualTheme.inkOf(context))),
          ],
        ),
      ),
    );
  }
}
