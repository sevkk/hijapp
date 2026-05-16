import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/widgets/credit_badge.dart';

void main() {
  testWidgets('CreditBadge shows count and suffix', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: CreditBadge(credits: 42))),
    ));
    expect(find.text('42'), findsOneWidget);
    expect(find.text('deneme'), findsOneWidget);
  });

  testWidgets('CreditBadge respects custom suffix', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: CreditBadge(credits: 5, suffix: 'kredi'))),
    ));
    expect(find.text('kredi'), findsOneWidget);
  });

  testWidgets('CreditBadge tap fires callback', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: CreditBadge(credits: 1, onTap: () => tapped++)),
      ),
    ));
    await tester.tap(find.byType(CreditBadge));
    await tester.pump();
    expect(tapped, 1);
  });
}
