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

    expect(find.byIcon(Icons.desk_rounded), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    expect(find.text('Desk'), findsOneWidget);
    expect(find.text('Workshops'), findsOneWidget);
    expect(find.text('Spark'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.local_fire_department_rounded));
    expect(picked, 2);
  });

  testWidgets('a recipe row renders its draft stage', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: VisualTheme.lightTheme,
      home: Scaffold(
        body: RecipeRow(
          kind: 'Caption',
          title: 'Saturday market opener',
          meta: 'Caption · 3 sparks',
          recall: 'Rough',
          accent: VisualTheme.clay,
          onTap: () {},
        ),
      ),
    ));

    expect(find.text('Saturday market opener'), findsOneWidget);
    expect(find.text('Rough'), findsOneWidget);
  });
}
