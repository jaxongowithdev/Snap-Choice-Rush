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
    _capacityController = TextEditingController(text: widget.container?.capacity.toString() ?? '12');
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
      appBar: AppBar(title: Text(isEditing ? 'EDIT RACK' : 'NEW RACK')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(key: const ValueKey('name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Rack name', hintText: 'e.g., Station A, Prep room'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Name this rack' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('code_field'), controller: _codeController, decoration: const InputDecoration(labelText: 'Well mark', hintText: 'e.g., LAB-01, STA-B'), textCapitalization: TextCapitalization.characters, validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a well mark' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('room_field'), controller: _roomController, decoration: const InputDecoration(labelText: 'Room / lab', hintText: 'e.g., Lab 2, Prep, Storage'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Where is this rack stored?' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('shelf_field'), controller: _shelfController, decoration: const InputDecoration(labelText: 'Bay / shelf', hintText: 'e.g., Bay 3, Left bench'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a bay or shelf' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('capacity_field'), controller: _capacityController, decoration: const InputDecoration(labelText: 'Well count'), keyboardType: TextInputType.number, validator: (v) { final n = int.tryParse(v?.trim() ?? ''); return (n == null || n <= 0) ? 'Use a positive number' : null; }),
            const SizedBox(height: 22),
            FilledButton(key: const ValueKey('save_button'), onPressed: _saveContainer, child: Text(isEditing ? 'SAVE RACK' : 'STAGE RACK')),
          ],
        ),
      ),
    );
  }
}
