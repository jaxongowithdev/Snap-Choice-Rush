import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_screen/user_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kettleleaf boots into a MaterialApp', (tester) async {
    await tester.pumpWidget(const UserScreen());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
