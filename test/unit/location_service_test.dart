import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/core/services/location_service.dart';

void main() {
  group('LocationService & PostGIS Spatial Alignment Tests (TASK-4.3)', () {
    const service = LocationService(isMock: true);

    test('Computes geodesic distance between Manhattan points accurately', () {
      // SoHo (40.7250, -73.9984) to Little Italy (40.7165, -73.9986)
      final meters = service.calculateDistanceInMeters(
        startLatitude: 40.7250,
        startLongitude: -73.9984,
        endLatitude: 40.7165,
        endLongitude: -73.9986,
      );

      // Distance is ~945 meters (~0.58 miles)
      expect(meters, greaterThan(800.0));
      expect(meters, lessThan(1100.0));

      final miles = service.calculateDistanceInMiles(
        startLatitude: 40.7250,
        startLongitude: -73.9984,
        endLatitude: 40.7165,
        endLongitude: -73.9986,
      );
      expect(miles, closeTo(0.58, 0.1));
    });

    test('Formats distance strings cleanly', () {
      expect(service.formatDistance(0.05), 'Less than 0.1 miles away');
      expect(service.formatDistance(0.42), '0.4 miles away');
      expect(service.formatDistance(1.86), '1.9 miles away');
    });

    test('Calculates delivery ETA according to BR-04 formula', () {
      // BR-04: ETA = 15m (prep) + (miles * 5m/mile) + 5m (buffer)
      // For 1.0 mile: 15 + 5 + 5 = 25 minutes
      expect(service.calculateEtaMinutes(1.0), 25);

      // For 0.2 miles: 15 + 1 + 5 = 21 minutes
      expect(service.calculateEtaMinutes(0.2), 21);

      // For 3.0 miles: 15 + 15 + 5 = 35 minutes
      expect(service.calculateEtaMinutes(3.0), 35);
    });

    test('Annotates and sorts restaurants by true proximity to user location', () {
      const userLoc = UserLocation(latitude: 40.7128, longitude: -74.0060); // City Hall

      // Restaurant A: Little Italy (closer to City Hall)
      const restA = Restaurant(
        imageUrl: 'assets/images/restaurant1.jpg',
        name: 'Bella Notte Trattoria',
        address: '88 Mulberry St',
        rating: 5,
        menu: <Food>[],
        latitude: 40.7165,
        longitude: -73.9986,
      );

      // Restaurant B: Sheepshead Bay (further from City Hall in South Brooklyn)
      const restB = Restaurant(
        imageUrl: 'assets/images/restaurant3.jpg',
        name: 'Taquería El Sol Mexican Grill',
        address: '1612 Emmons Ave',
        rating: 4,
        menu: <Food>[],
        latitude: 40.5842,
        longitude: -73.9515,
      );

      final sorted = service.annotateAndSortRestaurants([restB, restA], userLoc);

      // Closer restaurant (Bella Notte) must be sorted first
      expect(sorted.first.name, 'Bella Notte Trattoria');
      expect(sorted.last.name, 'Taquería El Sol Mexican Grill');
      expect(sorted.first.distance, contains('miles away'));
    });
  });
}
