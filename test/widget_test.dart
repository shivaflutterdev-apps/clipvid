// This is a basic Flutter Widget test.
import 'package:clipvid/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClipVidApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
