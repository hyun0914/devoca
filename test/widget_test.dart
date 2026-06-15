import 'package:flutter_test/flutter_test.dart';
import 'package:devoca/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const DevocaApp());
    expect(find.byType(DevocaApp), findsOneWidget);
  });
}
