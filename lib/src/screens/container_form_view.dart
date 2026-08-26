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
  String _track = VisualTheme.tracks.first;
  String _stage = 'Launch';

  static const _stages = ['Launch', 'Orbit', 'Cruise', 'Landing', 'Docked'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container?.name);
    _codeController = TextEditingController(text: widget.container?.code);
    _capacityController =
        TextEditingController(text: widget.container?.capacity.toString() ?? '12');
    final room = widget.container?.room;
    _track = (room != null && VisualTheme.tracks.contains(room))
        ? room
        : VisualTheme.tracks.first;
    final shelf = widget.container?.shelf;
    _stage = (shelf != null && _stages.contains(shelf)) ? shelf : 'Launch';
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
    final mission = ContainerModel(
      id: widget.container?.id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      room: _track,
      shelf: _stage,
      capacity: int.parse(_capacityController.text.trim()),
      createdAt: widget.container?.createdAt,
    );
    try {
      if (widget.container == null) {
        await _storage.createContainer(mission);
      } else {
        await _storage.updateContainer(mission);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Could not save mission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That mission code is already in use.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.container != null;
    return Scaffold(
      body: StarDust(
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
                Text(isEditing ? 'Edit mission' : 'New mission',
                    style: VisualTheme.display(30, color: VisualTheme.inkOf(context))),
                const SizedBox(height: 6),
                Text('Name the topic, give it a code, set how many cues you are aiming for.',
                    style: VisualTheme.body(14, color: VisualTheme.mutedOf(context))),
                const SizedBox(height: 24),
                BentoTile(
                  child: Column(
                    children: [
                      TextFormField(
                        key: const ValueKey('name_field'),
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Mission name',
                          hintText: 'e.g. Moons of Jupiter',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Name this mission' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('code_field'),
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Mission code',
                          hintText: 'e.g. MSN-04',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Add a short code' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const ValueKey('capacity_field'),
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Target cue count'),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          return (n == null || n <= 0) ? 'Use a positive number' : null;
                        },
                      ),
                    ],
                  ),
                ),
                const SectionHead(title: 'Track'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: VisualTheme.tracks
                      .map((t) => _Choice(
                            label: t,
                            icon: VisualTheme.trackIcon(t),
                            selected: _track == t,
                            onTap: () => setState(() => _track = t),
                          ))
                      .toList(),
                ),
                const SectionHead(title: 'Stage'),
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
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: Text(isEditing ? 'Save mission' : 'Launch mission'),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? VisualTheme.nova : VisualTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 15,
                  color: selected ? Colors.white : VisualTheme.mutedOf(context)),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: VisualTheme.heading(13.5,
                    color: selected ? Colors.white : VisualTheme.inkOf(context),
                    w: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
