// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:yazilim_muhendisligi_projesi/main.dart';

void main() {
  testWidgets('Hotel Check-in app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HotelCheckInApp());

    // Verify that our search screen is displayed.
    expect(find.text('Otel Check-in'), findsOneWidget);
    expect(find.text('Rezervasyonu Sorgula'), findsOneWidget);
  });
}
