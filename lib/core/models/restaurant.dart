import 'package:pos/core/models/food.dart';

class Restaurant {
  final String imageUrl;
  final String name;
  final String address;
  final int rating;
  final List<Food> menu;
  final String distance;
  final double? latitude;
  final double? longitude;

  const Restaurant({
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.rating,
    required this.menu,
    this.distance = '0.2 miles away',
    this.latitude,
    this.longitude,
  });

  Restaurant copyWith({
    String? imageUrl,
    String? name,
    String? address,
    int? rating,
    List<Food>? menu,
    String? distance,
    double? latitude,
    double? longitude,
  }) {
    return Restaurant(
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      menu: menu ?? this.menu,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Restaurant &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;
}
