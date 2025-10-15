import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexipdf/main.dart';

void main() {
  testWidgets('FlexiPDF app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlexiPdfApp());

    // Verify that the home screen loads
    expect(find.text('FlexiPDF'), findsOneWidget);
    expect(find.text('All your PDF tools, 100% offline'), findsOneWidget);
  });
}
