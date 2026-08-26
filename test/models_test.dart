import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/models/container_model.dart';
import 'package:user_screen/src/models/inventory_item_model.dart';
import 'package:user_screen/src/models/user_preferences.dart';

void main() {
  test('mission survives a map round trip', () {
    final mission = ContainerModel(
      id: 3,
      name: 'The Eight Planets',
      code: 'MSN-01',
      room: 'Planets',
      shelf: 'Launch',
      capacity: 8,
    );
    final back = ContainerModel.fromMap(mission.toMap());
    expect(back.name, mission.name);
    expect(back.code, mission.code);
    expect(back.room, mission.room);
    expect(back.capacity, 8);
  });

  test('cue defaults to Fresh and survives a map round trip', () {
    final cue = InventoryItemModel(
      id: 9,
      containerId: 3,
      name: 'The rusty red planet',
      category: 'Image',
      notes: 'Mars — a rusted red bicycle by the stairs.',
    );
    expect(cue.condition, 'Fresh');

    final back = InventoryItemModel.fromMap(cue.toMap());
    expect(back.name, cue.name);
    expect(back.category, 'Image');
    expect(back.condition, 'Fresh');
    expect(back.isFavorite, isFalse);
  });

  test('copyWith bumps reps without losing the rest', () {
    final cue = InventoryItemModel(containerId: 1, name: 'x', category: 'Peg');
    final drilled = cue.copyWith(quantity: cue.quantity + 1, condition: 'Locked');
    expect(drilled.quantity, cue.quantity + 1);
    expect(drilled.condition, 'Locked');
    expect(drilled.name, 'x');
  });

  test('preferences default to the mission prefix', () {
    final prefs = UserPreferences();
    expect(prefs.defaultBoxPrefix, 'MSN');
    expect(prefs.capacityUnit, 'cues');
    expect(prefs.showOnboarding, isTrue);
    expect(UserPreferences.fromMap(prefs.toMap()).theme, 'system');
  });
}
