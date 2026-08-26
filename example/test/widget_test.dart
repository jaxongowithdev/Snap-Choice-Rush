import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_screen/user_screen.dart';

void main() {
  testWidgets('the dock shows five tabs and reports taps', (tester) async {
    var picked = -1;
    await tester.pumpWidget(MaterialApp(
      theme: VisualTheme.lightTheme,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: OrbitDock(index: 0, onSelect: (i) => picked = i),
        ),
      ),
    ));

    expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.insights_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);

    // Only the active tab shows its label.
    expect(find.text('Deck'), findsOneWidget);
    expect(find.text('Missions'), findsNothing);

    await tester.tap(find.byIcon(Icons.bolt_rounded));
    expect(picked, 2);
  });

  testWidgets('a cue tile renders its recall level', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: VisualTheme.lightTheme,
      home: Scaffold(
        body: CueTile(
          kind: 'Image',
          title: 'The rusty red planet',
          meta: 'Image · 3 reps',
          recall: 'Shaky',
          accent: VisualTheme.flare,
          onTap: () {},
        ),
      ),
    ));

    expect(find.text('The rusty red planet'), findsOneWidget);
    expect(find.text('Shaky'), findsOneWidget);
  });
}
