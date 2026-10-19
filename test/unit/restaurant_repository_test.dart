import 'package:flutter_test/flutter_test.dart';
import 'package:pos/features/discovery/data/restaurant_repository.dart';

void main() {
  group('RestaurantRepository Unit Tests (Clean Architecture Repository Pattern)', () {
    late IRestaurantRepository repository;

    setUp(() {
      repository = MockRestaurantRepository();
    });

    test('getNearbyRestaurants returns populated list of restaurants', () {
      final restaurants = repository.getNearbyRestaurants();
      expect(restaurants, isNotEmpty);
      expect(restaurants.length, greaterThanOrEqualTo(5));
      expect(restaurants.first.name, isNotEmpty);
      expect(restaurants.first.menu, isNotEmpty);
    });

    test('getRecentOrders returns seeded past user orders', () {
      final recentOrders = repository.getRecentOrders();
      expect(recentOrders, isNotEmpty);
      expect(recentOrders.first.food.name, isNotEmpty);
      expect(recentOrders.first.restaurant.name, isNotEmpty);
    });

    test('searchRestaurants filters restaurants by name or menu dish name', () {
      final burgerResults = repository.searchRestaurants('Burger');
      expect(burgerResults, isNotEmpty);

      final specificResults = repository.searchRestaurants('Rustic Table');
      expect(specificResults, isNotEmpty);
      expect(specificResults.first.name, contains('The Rustic Table Bistro'));

      final emptyResults = repository.searchRestaurants('NonExistentFoodItemXYZ');
      expect(emptyResults, isEmpty);
    });

    test('getRestaurantByName returns matching restaurant or null', () {
      final found = repository.getRestaurantByName('Bella Notte Trattoria');
      expect(found, isNotNull);
      expect(found?.address, contains('Mulberry St'));

      final notFound = repository.getRestaurantByName('NonExistentPlace');
      expect(notFound, isNull);
    });
  });
}
