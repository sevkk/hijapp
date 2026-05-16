import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijapp/core/widgets/brand_button.dart';

void main() {
  testWidgets('BrandButton renders label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrandButton(label: 'Dene', onPressed: () {}),
      ),
    ));
    expect(find.text('Dene'), findsOneWidget);
  });

  testWidgets('BrandButton is disabled when onPressed is null', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BrandButton(label: 'Dene', onPressed: null),
      ),
    ));
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('loading shows spinner instead of label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrandButton(label: 'Submit', onPressed: () {}, loading: true),
      ),
    ));
    expect(find.text('Submit'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('secondary variant renders OutlinedButton', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrandButton(
          label: 'Vazgec',
          onPressed: () {},
          variant: BrandButtonVariant.secondary,
        ),
      ),
    ));
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('ghost variant renders TextButton', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrandButton(
          label: 'Atla',
          onPressed: () {},
          variant: BrandButtonVariant.ghost,
        ),
      ),
    ));
    expect(find.byType(TextButton), findsOneWidget);
  });
}
