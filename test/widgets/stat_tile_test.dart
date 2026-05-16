import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/widgets/stat_tile.dart';

void main() {
  testWidgets('renders label, value and delta', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: StatTile(
          label: 'Bu ay deneme',
          value: '1.234',
          delta: '+12%',
          deltaPositive: true,
          icon: Icons.trending_up,
        ),
      ),
    ));
    expect(find.text('Bu ay deneme'), findsOneWidget);
    expect(find.text('1.234'), findsOneWidget);
    expect(find.text('+12%'), findsOneWidget);
  });

  testWidgets('omits delta when null', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: StatTile(label: 'Kullanici', value: '0'),
      ),
    ));
    expect(find.text('Kullanici'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsNothing);
    expect(find.byIcon(Icons.trending_down), findsNothing);
  });
}
