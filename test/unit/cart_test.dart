import 'package:flutter_test/flutter_test.dart';
import 'package:pos/models/food.dart';
import 'package:pos/models/order.dart';
import 'package:pos/models/restaurant.dart';

void main() {
  group('Cart Logic & Pricing Tests (TDD - FR-COS-04 & FR-COS-05)', () {
    const foodA = Food(name: 'Burger', imageUrl: 'assets/images/burger.jpg', price: 14.99);
    const foodB = Food(name: 'Pizza', imageUrl: 'assets/images/pizza.jpg', price: 11.99);
    const restaurant = Restaurant(
      imageUrl: 'assets/images/restaurant2.jpg',
      name: 'Restaurant 2',
      address: '200 Main St, New York, NY',
      rating: 4,
      menu: [foodA, foodB],
    );

    test('Computes grand total correctly from multiple cart items', () {
      final cart = [
        Order(restaurant: restaurant, food: foodA, date: 'Oct 18, 2026', quantity: 2), // 2 * 14.99 = 29.98
        Order(restaurant: restaurant, food: foodB, date: 'Oct 18, 2026', quantity: 1), // 1 * 11.99 = 11.99
      ];

      double total = 0.0;
      for (var order in cart) {
        total += order.quantity * order.food.price;
      }

      expect(total, closeTo(41.97, 0.001));
      expect(total.toStringAsFixed(2), '41.97');
    });

    test('Line item subtotal updates proportionally when quantity increments', () {
      final item = Order(restaurant: restaurant, food: foodA, date: 'Oct 18, 2026', quantity: 1);
      expect(item.quantity * item.food.price, 14.99);

      final incremented = Order(
        restaurant: item.restaurant,
        food: item.food,
        date: item.date,
        quantity: item.quantity + 1,
      );
      expect(incremented.quantity * incremented.food.price, 29.98);
    });
  });
}
