import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/user_screen.dart';

void main() {
  testWidgets('the desk rail shows five labelled tabs and reports taps', (tester) async {
    var picked = -1;
    await tester.pumpWidget(MaterialApp(
      theme: VisualTheme.lightTheme,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: DeskRail(index: 0, onSelect: (i) => picked = i),
        ),
      ),
    ));

    expect(find.byIcon(Icons.table_restaurant_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.byIcon(Icons.emoji_food_beverage_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    expect(find.text('Bench'), findsOneWidget);
    expect(find.text('Caddies'), findsOneWidget);
    expect(find.text('Cupping'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.emoji_food_beverage_rounded));
    expect(picked, 2);
  });

  testWidgets('a leaf row renders its steep stage', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: VisualTheme.lightTheme,
      home: Scaffold(
        body: RecipeRow(
          kind: 'Aroma',
          title: 'Longjing, west lake',
          meta: 'Aroma · 3 cuppings',
          recall: 'First',
          accent: VisualTheme.clay,
          onTap: () {},
        ),
      ),
    ));

    expect(find.text('Longjing, west lake'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
  });
}
