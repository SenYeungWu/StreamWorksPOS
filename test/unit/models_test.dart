import 'package:flutter_test/flutter_test.dart';
import 'package:pos/models/food.dart';
import 'package:pos/models/order.dart';
import 'package:pos/models/restaurant.dart';
import 'package:pos/models/user.dart';

void main() {
  group('Domain Models & Calculation Tests (TDD)', () {
    test('Food model instantiates with required attributes', () {
      const food = Food(
        name: 'Burrito',
        imageUrl: 'assets/images/burrito.jpg',
        price: 8.99,
      );

      expect(food.name, 'Burrito');
      expect(food.imageUrl, 'assets/images/burrito.jpg');
      expect(food.price, 8.99);
    });

    test('Order calculation computes correct line item subtotal', () {
      const food = Food(
        name: 'Steak',
        imageUrl: 'assets/images/steak.jpg',
        price: 17.99,
      );
      const restaurant = Restaurant(
        imageUrl: 'assets/images/restaurant0.jpg',
        name: 'Restaurant 0',
        address: '200 Main St, New York, NY',
        rating: 5,
        menu: [food],
      );
      final order = Order(
        restaurant: restaurant,
        food: food,
        date: 'Jan 10, 2026',
        quantity: 3,
      );

      final subtotal = order.quantity * order.food.price;
      expect(subtotal, closeTo(53.97, 0.001));
    });

    test('User model holds distinct orders and active cart lists', () {
      const food = Food(name: 'Pasta', imageUrl: 'assets/images/pasta.jpg', price: 14.99);
      const restaurant = Restaurant(
        imageUrl: 'assets/images/restaurant1.jpg',
        name: 'Restaurant 1',
        address: '100 Broadway, NY',
        rating: 4,
        menu: [food],
      );
      final historyOrder = Order(
        restaurant: restaurant,
        food: food,
        date: 'Jan 1, 2026',
        quantity: 1,
      );
      final activeCartOrder = Order(
        restaurant: restaurant,
        food: food,
        date: 'Jan 18, 2026',
        quantity: 2,
      );

      final user = User(
        name: 'Rebecca',
        orders: [historyOrder],
        cart: [activeCartOrder],
      );

      expect(user.orders.length, 1);
      expect(user.cart.length, 1);
      expect(user.cart.first.quantity, 2);
      expect(user.orders.first.quantity, 1);
    });
  });
}
