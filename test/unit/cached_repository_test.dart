import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/order.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/discovery/data/restaurant_repository.dart';

class FailingRemoteRepository implements IRestaurantRepository {
  bool shouldFail = false;

  final sampleRestaurants = const [
    Restaurant(
      imageUrl: 'assets/images/restaurant0.jpg',
      name: 'Cached Bistro',
      address: '100 Main St',
      rating: 5,
      menu: <Food>[],
    ),
  ];

  @override
  List<Restaurant> getNearbyRestaurants() {
    if (shouldFail) {
      throw Exception('Network disconnected (Airplane Mode)');
    }
    return sampleRestaurants;
  }

  @override
  List<Order> getRecentOrders() {
    if (shouldFail) {
      throw Exception('Network disconnected');
    }
    return const [];
  }

  @override
  List<Restaurant> searchRestaurants(String query) {
    if (shouldFail) {
      throw Exception('Network disconnected');
    }
    return sampleRestaurants;
  }

  @override
  Restaurant? getRestaurantByName(String name) {
    if (shouldFail) {
      throw Exception('Network disconnected');
    }
    return sampleRestaurants.first;
  }
}

void main() {
  group('CachedRestaurantRepository Offline Resilience Tests (TASK-4.6)', () {
    test('Caches remote data on successful fetch and falls back during network failure', () {
      final remote = FailingRemoteRepository();
      final cachedRepo = CachedRestaurantRepository(remoteRepository: remote);

      // 1. Initial online fetch populates cache
      final onlineRestaurants = cachedRepo.getNearbyRestaurants();
      expect(onlineRestaurants.length, 1);
      expect(onlineRestaurants.first.name, 'Cached Bistro');
      expect(cachedRepo.hasCache, isTrue);

      // 2. Simulate network dropout (airplane mode)
      remote.shouldFail = true;

      // 3. Requesting restaurants during dropout still returns cached listings
      final offlineRestaurants = cachedRepo.getNearbyRestaurants();
      expect(offlineRestaurants.length, 1);
      expect(offlineRestaurants.first.name, 'Cached Bistro');

      // 4. Searching offline uses cached data
      final searchResult = cachedRepo.searchRestaurants('Bistro');
      expect(searchResult.length, 1);
      expect(searchResult.first.name, 'Cached Bistro');
    });
  });
}
