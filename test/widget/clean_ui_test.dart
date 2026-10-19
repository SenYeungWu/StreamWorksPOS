import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/data.dart';
import 'package:pos/widgets/recent_orders.dart';

void main() {
  testWidgets('RecentOrders renders authentic dish names without debug artifacts', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(primaryColor: Colors.deepOrangeAccent),
          home: const Scaffold(
            body: RecentOrders(),
          ),
        ),
      ),
    );

    // Verify debug artifact 'bla bla bla' does NOT appear in the widget tree
    expect(find.textContaining('bla bla bla'), findsNothing);

    // Verify authentic food name from first order appears
    final firstOrderFoodName = currentUser.orders.first.food.name;
    expect(find.textContaining(firstOrderFoodName), findsWidgets);
  });
}
