import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/models/container_model.dart';
import 'package:user_screen/src/models/inventory_item_model.dart';
import 'package:user_screen/src/models/user_preferences.dart';

void main() {
  test('caddy survives a map round trip', () {
    final caddy = ContainerModel(
      id: 3,
      name: 'Morning greens',
      code: 'CAD-01',
      room: 'Green',
      shelf: 'First flush',
      capacity: 6,
    );
    final back = ContainerModel.fromMap(caddy.toMap());
    expect(back.name, caddy.name);
    expect(back.code, caddy.code);
    expect(back.room, caddy.room);
    expect(back.capacity, 6);
  });

  test('leaf defaults to Dry and survives a map round trip', () {
    final leaf = InventoryItemModel(
      id: 9,
      containerId: 3,
      name: 'Longjing, west lake',
      category: 'Aroma',
      notes: 'Chestnut dry leaf. 80C, 45 seconds.',
    );
    expect(leaf.condition, 'Dry');

    final back = InventoryItemModel.fromMap(leaf.toMap());
    expect(back.name, leaf.name);
    expect(back.category, 'Aroma');
    expect(back.condition, 'Dry');
    expect(back.isFavorite, isFalse);
  });

  test('copyWith bumps cuppings without losing the rest', () {
    final leaf = InventoryItemModel(containerId: 1, name: 'x', category: 'Steep');
    final cupped = leaf.copyWith(quantity: leaf.quantity + 1, condition: 'Cellared');
    expect(cupped.quantity, leaf.quantity + 1);
    expect(cupped.condition, 'Cellared');
    expect(cupped.name, 'x');
  });

  test('preferences default to the caddy prefix', () {
    final prefs = UserPreferences();
    expect(prefs.defaultBoxPrefix, 'CAD');
    expect(prefs.capacityUnit, 'leaves');
    expect(prefs.showOnboarding, isTrue);
    expect(UserPreferences.fromMap(prefs.toMap()).theme, 'system');
  });
}
