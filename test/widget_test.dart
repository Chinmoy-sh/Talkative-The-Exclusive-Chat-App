// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talkative/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await tester.pumpWidget(const TalkativeApp());

    // Let first frame and microtasks settle (e.g., async init guarded in app)
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Expect the app scaffolded with Material
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
