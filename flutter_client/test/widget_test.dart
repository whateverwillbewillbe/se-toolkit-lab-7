// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_client/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LmsApp());

    // Verify that the app loads with the bottom navigation bar
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify that the Labs tab is present
    expect(find.text('Labs'), findsOneWidget);
    
    // Verify that the Learners tab is present
    expect(find.text('Learners'), findsOneWidget);
    
    // Verify that the Interactions tab is present
    expect(find.text('Interactions'), findsOneWidget);
  });
}
