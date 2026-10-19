import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/cart/domain/cart_item.dart';
import 'package:pos/features/cart/domain/cart_state.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';
import 'package:pos/screens/cart_screen.dart';

void main() {
  testWidgets('CartScreen displays active cart items and increments quantity interactively', (WidgetTester tester) async {
    // Seed isolated cart item
    const food = Food(name: 'Test Burrito', imageUrl: 'assets/images/burrito.jpg', price: 10.00);
    const restaurant = Restaurant(
      imageUrl: 'assets/images/restaurant0.jpg',
      name: 'Test Bistro',
      address: '123 Main St',
      rating: 5,
      menu: [food],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cartProvider.overrideWith(
            () => CartController(
              const CartState(
                items: [CartItem(food: food, restaurant: restaurant, quantity: 1)],
                currentRestaurant: restaurant,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.deepOrangeAccent,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
          ),
          home: const CartScreen(),
        ),
      ),
    );

    // Verify the cart item name is displayed
    expect(find.text('Test Burrito'), findsOneWidget);

    // Verify initial line item price and total cost ($10.00) are rendered
    expect(find.text('\$10.00'), findsNWidgets(2));

    // Verify quantity is initially 1
    expect(find.text('1'), findsOneWidget);

    // Tap the '+' button to increment quantity
    await tester.tap(find.text('+'));
    await tester.pump();

    // Verify quantity is now 2
    expect(find.text('2'), findsOneWidget);

    // Verify updated price ($20.00) is rendered
    expect(find.text('\$20.00'), findsNWidgets(2));

    // Verify CHECKOUT button is visible
    expect(find.text('CHECKOUT'), findsOneWidget);

    // Tap CHECKOUT to open the interactive Stripe Checkout bottom sheet
    await tester.tap(find.text('CHECKOUT'));
    await tester.pumpAndSettle();

    // Verify Stripe modal elements are rendered
    expect(find.text('Stripe Checkout'), findsOneWidget);
    expect(find.text('TEST MODE'), findsOneWidget);
    expect(find.text('2000 cents'), findsOneWidget);
    expect(find.text('Pay \$20.00 with Stripe'), findsOneWidget);

    // Tap Pay button and verify payment processing and transition
    await tester.tap(find.text('Pay \$20.00 with Stripe'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify Stripe sheet closed upon successful settlement
    expect(find.text('Stripe Checkout'), findsNothing);
  });
}
