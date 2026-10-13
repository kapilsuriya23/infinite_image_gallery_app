import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery_app/core/widgets/error_view.dart';

void main() {
  testWidgets('ErrorView shows message and fires onRetry', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: ErrorView(message: 'Oops', onRetry: () => tapped = true),
    ));
    expect(find.text('Oops'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(tapped, isTrue);
  });
}
