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
    _capacityController = TextEditingController(text: widget.container?.capacity.toString() ?? '24');
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
      appBar: AppBar(title: Text(isEditing ? 'Edit book' : 'New book')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            TextFormField(key: const ValueKey('name_field'), controller: _nameController, decoration: const InputDecoration(labelText: 'Book name', hintText: 'e.g., Studio Czerny, Recital folder'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Name this book' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('code_field'), controller: _codeController, decoration: const InputDecoration(labelText: 'Clef mark', hintText: 'e.g., CLEF-01, REC'), textCapitalization: TextCapitalization.characters, validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a clef mark' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('room_field'), controller: _roomController, decoration: const InputDecoration(labelText: 'Studio / room', hintText: 'e.g., Studio B, Home piano'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Where does this book live?' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('shelf_field'), controller: _shelfController, decoration: const InputDecoration(labelText: 'Stand / shelf', hintText: 'e.g., Music stand, Left shelf'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a stand or shelf' : null),
            const SizedBox(height: 12),
            TextFormField(key: const ValueKey('capacity_field'), controller: _capacityController, decoration: const InputDecoration(labelText: 'Bar / slot count'), keyboardType: TextInputType.number, validator: (v) { final n = int.tryParse(v?.trim() ?? ''); return (n == null || n <= 0) ? 'Use a positive number' : null; }),
            const SizedBox(height: 22),
            FilledButton(key: const ValueKey('save_button'), onPressed: _saveContainer, child: Text(isEditing ? 'Save book' : 'Stage book')),
          ],
        ),
      ),
    );
  }
}
