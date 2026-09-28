import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savings/core/jar_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every category image is bundled (declared in pubspec)', () async {
    for (final key in kJarIcons.keys) {
      final data = await rootBundle.load(jarImagePath(key));
      expect(data.lengthInBytes, greaterThan(0), reason: key);
    }
  });

  testWidgets('every category renders its image', (tester) async {
    for (final key in kJarIcons.keys) {
      await tester.pumpWidget(MaterialApp(
        home: buildJarIcon(key, imageSize: 100, iconColor: Colors.white),
      ));
      expect(find.byType(Image), findsOneWidget, reason: key);
    }
  });

  testWidgets('unknown category falls back to the piggy bank icon', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: buildJarIcon('unknown', imageSize: 100, iconColor: Colors.white),
    ));
    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
  });
}
