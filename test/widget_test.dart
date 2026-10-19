import 'package:flutter_test/flutter_test.dart';
import 'package:pos/main.dart';

void main() {
  testWidgets('Stream Works main app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify AppBar title is present
    expect(find.text('Stream Works'), findsOneWidget);

    // Verify Cart counter button is present with initial clean count of 0
    expect(find.text('Cart (0)'), findsOneWidget);

    // Verify Recent Orders section header is present
    expect(find.text('Recent Orders'), findsOneWidget);

    // Verify Nearby Restaurants section header is present
    expect(find.text('Nearby Restaurants'), findsOneWidget);
  });
}
