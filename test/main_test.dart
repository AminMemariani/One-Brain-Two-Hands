import 'package:flutter_test/flutter_test.dart';
import 'package:one_brain_two_hands/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MyApp builds without errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('MyApp has correct title', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'One Brain Two Hands');
  });

  testWidgets('MyApp uses Material3', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });

  testWidgets('MyApp does not show debug banner', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
  });
}

