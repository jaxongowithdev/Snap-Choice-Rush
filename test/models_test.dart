import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/src/models/container_model.dart';
import 'package:user_screen/src/models/inventory_item_model.dart';
import 'package:user_screen/src/models/user_preferences.dart';

void main() {
  test('workshop survives a map round trip', () {
    final workshop = ContainerModel(
      id: 3,
      name: 'Shop window copy',
      code: 'WKS-01',
      room: 'Product',
      shelf: 'Drafting',
      capacity: 6,
    );
    final back = ContainerModel.fromMap(workshop.toMap());
    expect(back.name, workshop.name);
    expect(back.code, workshop.code);
    expect(back.room, workshop.room);
    expect(back.capacity, 6);
  });

  test('recipe defaults to Seed and survives a map round trip', () {
    final recipe = InventoryItemModel(
      id: 9,
      containerId: 3,
      name: 'Saturday market opener',
      category: 'Caption',
      notes: 'Heirloom tomatoes, still warm.',
    );
    expect(recipe.condition, 'Seed');

    final back = InventoryItemModel.fromMap(recipe.toMap());
    expect(back.name, recipe.name);
    expect(back.category, 'Caption');
    expect(back.condition, 'Seed');
    expect(back.isFavorite, isFalse);
  });

  test('copyWith bumps sparks without losing the rest', () {
    final recipe = InventoryItemModel(containerId: 1, name: 'x', category: 'Hook');
    final sparked = recipe.copyWith(quantity: recipe.quantity + 1, condition: 'Ready');
    expect(sparked.quantity, recipe.quantity + 1);
    expect(sparked.condition, 'Ready');
    expect(sparked.name, 'x');
  });

  test('preferences default to the workshop prefix', () {
    final prefs = UserPreferences();
    expect(prefs.defaultBoxPrefix, 'WKS');
    expect(prefs.capacityUnit, 'recipes');
    expect(prefs.showOnboarding, isTrue);
    expect(UserPreferences.fromMap(prefs.toMap()).theme, 'system');
  });
}
