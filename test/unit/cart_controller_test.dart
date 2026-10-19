import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';

void main() {
  group('CartController Unit Tests (TDD - BR-01 & BR-02)', () {
    late ProviderContainer container;
    late CartController cartController;

    const restaurantA = Restaurant(
      imageUrl: 'assets/images/restaurant0.jpg',
      name: 'The Rustic Table Bistro',
      address: '142 Mercer St, SoHo, NY',
      rating: 5,
      menu: [],
      distance: '0.2 miles away',
    );

    const restaurantB = Restaurant(
      imageUrl: 'assets/images/restaurant1.jpg',
      name: 'Bella Notte Trattoria',
      address: '88 Mulberry St, Little Italy, NY',
      rating: 4,
      menu: [],
      distance: '0.4 miles away',
    );

    const burger = Food(
      name: 'Truffle Wagyu Burger',
      imageUrl: 'assets/images/burger.jpg',
      price: 15.00,
    );

    const pasta = Food(
      name: 'Truffle Tagliatelle Carbonara',
      imageUrl: 'assets/images/pasta.jpg',
      price: 20.00,
    );

    setUp(() {
      container = ProviderContainer();
      cartController = container.read(cartProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial cart state is empty with 0 items and 0.00 subtotal', () {
      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.itemCount, 0);
      expect(state.subtotal, 0.0);
      expect(state.currentRestaurant, isNull);
    });

    test('Adding an item adds it to cart and updates subtotal and restaurant', () {
      final success = cartController.addItem(burger, restaurantA);
      final state = container.read(cartProvider);

      expect(success, isTrue);
      expect(state.items.length, 1);
      expect(state.itemCount, 1);
      expect(state.subtotal, 15.00);
      expect(state.currentRestaurant?.name, restaurantA.name);
    });

    test('Adding same item increments quantity rather than adding duplicate row', () {
      cartController.addItem(burger, restaurantA);
      final success = cartController.addItem(burger, restaurantA);
      final state = container.read(cartProvider);

      expect(success, isTrue);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 2);
      expect(state.itemCount, 2);
      expect(state.subtotal, 30.00);
    });

    test('BR-01: Adding item from different restaurant fails single-merchant policy', () {
      cartController.addItem(burger, restaurantA);
      final success = cartController.addItem(pasta, restaurantB);
      final state = container.read(cartProvider);

      // Fails due to single-merchant conflict
      expect(success, isFalse);
      // Cart still contains only restaurantA's item
      expect(state.items.length, 1);
      expect(state.currentRestaurant?.name, restaurantA.name);
    });

    test('BR-01: forceAddItem clears previous restaurant items and accepts new restaurant', () {
      cartController.addItem(burger, restaurantA);
      expect(container.read(cartProvider).currentRestaurant?.name, restaurantA.name);

      cartController.forceAddItem(pasta, restaurantB);
      final state = container.read(cartProvider);

      expect(state.items.length, 1);
      expect(state.items.first.food.name, pasta.name);
      expect(state.currentRestaurant?.name, restaurantB.name);
      expect(state.subtotal, 20.00);
    });

    test('BR-02: Increment quantity increases quantity and subtotal up to 99', () {
      cartController.addItem(burger, restaurantA);
      final item = container.read(cartProvider).items.first;

      cartController.incrementQuantity(item);
      var state = container.read(cartProvider);
      expect(state.items.first.quantity, 2);
      expect(state.subtotal, 30.00);

      // Force quantity to 99
      for (int i = 0; i < 110; i++) {
        cartController.incrementQuantity(container.read(cartProvider).items.first);
      }
      state = container.read(cartProvider);
      expect(state.items.first.quantity, 99);
    });

    test('BR-02: Decrement quantity decreases quantity or removes when reaching 0', () {
      cartController.addItem(burger, restaurantA);
      cartController.addItem(burger, restaurantA); // quantity = 2
      expect(container.read(cartProvider).items.first.quantity, 2);

      cartController.decrementQuantity(container.read(cartProvider).items.first);
      expect(container.read(cartProvider).items.first.quantity, 1);

      // Decrementing from 1 removes the item and resets restaurant if cart is empty
      cartController.decrementQuantity(container.read(cartProvider).items.first);
      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.currentRestaurant, isNull);
    });

    test('removeItem removes specific item from cart', () {
      cartController.addItem(burger, restaurantA);
      const secondFood = Food(name: 'Fries', imageUrl: 'assets/images/burger.jpg', price: 5.00);
      cartController.addItem(secondFood, restaurantA);
      expect(container.read(cartProvider).items.length, 2);

      final friesItem = container.read(cartProvider).items.firstWhere((i) => i.food.name == 'Fries');
      cartController.removeItem(friesItem);

      final state = container.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.food.name, burger.name);
    });

    test('clearCart empties cart and resets state', () {
      cartController.addItem(burger, restaurantA);
      cartController.clearCart();

      final state = container.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.itemCount, 0);
      expect(state.subtotal, 0.0);
      expect(state.currentRestaurant, isNull);
    });
  });
}
