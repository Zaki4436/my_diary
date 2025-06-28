import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_diary/main.dart';

void main() {
  testWidgets('Diary app UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(DiaryApp());

    expect(find.text('My Diary'), findsOneWidget);

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}
