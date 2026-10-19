import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/discovery/data/restaurant_repository.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final bool isDefault;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  // Default coordinate: Downtown Manhattan / New York City Hall
  static const defaultLocation = UserLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    isDefault: true,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class LocationService {
  final bool isMock;
  final UserLocation? mockLocation;

  const LocationService({this.isMock = false, this.mockLocation});

  /// Retrieves the current user position, falling back to NYC default if
  /// services or permissions are disabled or in automated testing environments.
  Future<UserLocation> getCurrentLocation() async {
    if (isMock && mockLocation != null) {
      return mockLocation!;
    }

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return UserLocation.defaultLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return UserLocation.defaultLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return UserLocation.defaultLocation;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        isDefault: false,
      );
    } catch (_) {
      return UserLocation.defaultLocation;
    }
  }

  /// Calculates geodesic distance in meters between two coordinates.
  double calculateDistanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculates distance in miles between user and merchant.
  double calculateDistanceInMiles({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final meters = calculateDistanceInMeters(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );
    return meters * 0.000621371;
  }

  /// Formats mileage string (e.g., "0.4 miles away").
  String formatDistance(double miles) {
    if (miles < 0.1) {
      return 'Less than 0.1 miles away';
    }
    return '${miles.toStringAsFixed(1)} miles away';
  }

  /// Calculates ETA in minutes according to Business Rule BR-04:
  /// ETA = 15m (prep) + (distance_miles * 5m/mile) + 5m (buffer)
  int calculateEtaMinutes(double miles) {
    final eta = 15.0 + (miles * 5.0) + 5.0;
    return math.max(15, eta.round());
  }

  /// Decorates a list of restaurants with dynamic real-time distance and ETA
  /// relative to the given coordinates, sorted from nearest to furthest.
  List<Restaurant> annotateAndSortRestaurants(
    List<Restaurant> restaurants,
    UserLocation userLocation,
  ) {
    final annotated = restaurants.map((restaurant) {
      if (restaurant.latitude == null || restaurant.longitude == null) {
        return restaurant;
      }

      final miles = calculateDistanceInMiles(
        startLatitude: userLocation.latitude,
        startLongitude: userLocation.longitude,
        endLatitude: restaurant.latitude!,
        endLongitude: restaurant.longitude!,
      );

      return restaurant.copyWith(
        distance: formatDistance(miles),
      );
    }).toList();

    annotated.sort((a, b) {
      if (a.latitude == null || b.latitude == null) return 0;
      final distA = calculateDistanceInMeters(
        startLatitude: userLocation.latitude,
        startLongitude: userLocation.longitude,
        endLatitude: a.latitude!,
        endLongitude: a.longitude!,
      );
      final distB = calculateDistanceInMeters(
        startLatitude: userLocation.latitude,
        startLongitude: userLocation.longitude,
        endLatitude: b.latitude!,
        endLongitude: b.longitude!,
      );
      return distA.compareTo(distB);
    });

    return annotated;
  }
}

// -----------------------------------------------------------------------------
// Riverpod Providers for Geolocation & Proximity Discovery (TASK-4.3)
// -----------------------------------------------------------------------------

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final userLocationProvider = FutureProvider<UserLocation>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.getCurrentLocation();
});

final nearbyRestaurantsWithDistanceProvider = Provider<List<Restaurant>>((ref) {
  final repo = ref.watch(restaurantRepositoryProvider);
  final service = ref.watch(locationServiceProvider);
  final locationAsync = ref.watch(userLocationProvider);

  final userLoc = locationAsync.asData?.value ?? UserLocation.defaultLocation;
  final baseRestaurants = repo.getNearbyRestaurants();

  return service.annotateAndSortRestaurants(baseRestaurants, userLoc);
});
