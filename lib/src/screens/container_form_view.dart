import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';

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
  late TextEditingController _roomController;
  late TextEditingController _shelfController;
  late TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container?.name);
    _codeController = TextEditingController(text: widget.container?.code);
    _roomController = TextEditingController(text: widget.container?.room);
    _shelfController = TextEditingController(text: widget.container?.shelf);
    _capacityController = TextEditingController(text: widget.container?.capacity.toString() ?? '70');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _roomController.dispose();
    _shelfController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveContainer() async {
    if (!_formKey.currentState!.validate()) return;
    final container = ContainerModel(
      id: widget.container?.id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      room: _roomController.text.trim(),
      shelf: _shelfController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
    );
    if (widget.container == null) {
      await _storage.createContainer(container);
    } else {
      await _storage.updateContainer(container);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.container != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit cask' : 'New cask')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(key: const ValueKey('name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Cask name', hintText: 'e.g., Linear tin, Spare bag', prefixIcon: Icon(Icons.inventory_2_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Name this cask' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('code_field'), controller: _codeController, decoration: const InputDecoration(labelText: 'Cask mark', hintText: 'e.g., SW-01, GATERON', prefixIcon: Icon(Icons.tag)), textCapitalization: TextCapitalization.characters, validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a cask mark' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('room_field'), controller: _roomController, decoration: const InputDecoration(labelText: 'Desk / drawer', hintText: 'e.g., Office, Closet, Bag', prefixIcon: Icon(Icons.desktop_windows_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Where is this cask stored?' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('shelf_field'), controller: _shelfController, decoration: const InputDecoration(labelText: 'Tray / slot', hintText: 'e.g., Top drawer, Left tray', prefixIcon: Icon(Icons.view_week_outlined)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a tray or slot' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('capacity_field'), controller: _capacityController, decoration: const InputDecoration(labelText: 'Switch slots', prefixIcon: Icon(Icons.stacked_bar_chart)), keyboardType: TextInputType.number, validator: (v) { final n = int.tryParse(v?.trim() ?? ''); return (n == null || n <= 0) ? 'Use a positive number' : null; }),
            const SizedBox(height: 22),
            FilledButton(key: const ValueKey('save_button'), onPressed: _saveContainer, child: Text(isEditing ? 'Save cask' : 'Stage cask')),
          ],
        ),
      ),
    );
  }
}
