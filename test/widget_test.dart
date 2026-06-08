import 'package:flutter_test/flutter_test.dart';
import 'package:carveplus_cut_pro/main.dart';

void main() {
  testWidgets('Carveplus app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CarveplusApp());

    expect(find.text('Carveplus Cut Pro'), findsOneWidget);
  });
}
