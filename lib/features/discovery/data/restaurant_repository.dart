import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/order.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/data/data.dart' as seed_data;

abstract class IRestaurantRepository {
  List<Restaurant> getNearbyRestaurants();
  List<Order> getRecentOrders();
  List<Restaurant> searchRestaurants(String query);
  Restaurant? getRestaurantByName(String name);
}

class MockRestaurantRepository implements IRestaurantRepository {
  @override
  List<Restaurant> getNearbyRestaurants() {
    return List.unmodifiable(seed_data.restaurants);
  }

  @override
  List<Order> getRecentOrders() {
    return List.unmodifiable(seed_data.currentUser.orders);
  }

  @override
  List<Restaurant> searchRestaurants(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return getNearbyRestaurants();

    return seed_data.restaurants.where((restaurant) {
      final matchesName = restaurant.name.toLowerCase().contains(cleanQuery);
      final matchesDish = restaurant.menu.any(
        (food) => food.name.toLowerCase().contains(cleanQuery),
      );
      return matchesName || matchesDish;
    }).toList();
  }

  @override
  Restaurant? getRestaurantByName(String name) {
    try {
      return seed_data.restaurants.firstWhere(
        (r) => r.name.toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Offline Caching & Network Resilience Decorator (TASK-4.6)
class CachedRestaurantRepository implements IRestaurantRepository {
  final IRestaurantRepository _remoteRepository;
  List<Restaurant>? _cachedRestaurants;
  List<Order>? _cachedOrders;
  DateTime? _lastCacheTime;

  CachedRestaurantRepository({IRestaurantRepository? remoteRepository})
      : _remoteRepository = remoteRepository ?? MockRestaurantRepository();

  bool get hasCache => _cachedRestaurants != null && _cachedRestaurants!.isNotEmpty;
  DateTime? get lastCacheTime => _lastCacheTime;

  @override
  List<Restaurant> getNearbyRestaurants() {
    try {
      final remote = _remoteRepository.getNearbyRestaurants();
      if (remote.isNotEmpty) {
        _cachedRestaurants = List.unmodifiable(remote);
        _lastCacheTime = DateTime.now();
        return _cachedRestaurants!;
      }
    } catch (_) {
      // Fallback to local cache during network dropouts
    }
    return _cachedRestaurants ?? _remoteRepository.getNearbyRestaurants();
  }

  @override
  List<Order> getRecentOrders() {
    try {
      final orders = _remoteRepository.getRecentOrders();
      if (orders.isNotEmpty) {
        _cachedOrders = List.unmodifiable(orders);
        return _cachedOrders!;
      }
    } catch (_) {
      // Fallback to local cache during network dropouts
    }
    return _cachedOrders ?? _remoteRepository.getRecentOrders();
  }

  @override
  List<Restaurant> searchRestaurants(String query) {
    final base = getNearbyRestaurants();
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return base;

    return base.where((restaurant) {
      final matchesName = restaurant.name.toLowerCase().contains(cleanQuery);
      final matchesDish = restaurant.menu.any(
        (food) => food.name.toLowerCase().contains(cleanQuery),
      );
      return matchesName || matchesDish;
    }).toList();
  }

  @override
  Restaurant? getRestaurantByName(String name) {
    final base = getNearbyRestaurants();
    try {
      return base.firstWhere(
        (r) => r.name.toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void invalidateCache() {
    _cachedRestaurants = null;
    _cachedOrders = null;
    _lastCacheTime = null;
  }
}

final restaurantRepositoryProvider = Provider<IRestaurantRepository>((ref) {
  return CachedRestaurantRepository();
});

final nearbyRestaurantsProvider = Provider<List<Restaurant>>((ref) {
  return ref.watch(restaurantRepositoryProvider).getNearbyRestaurants();
});

final recentOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(restaurantRepositoryProvider).getRecentOrders();
});
