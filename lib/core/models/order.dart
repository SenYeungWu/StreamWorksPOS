import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';

class Order {
  final Restaurant restaurant;
  final Food food;
  final String date;
  int quantity;

  Order({
    required this.restaurant,
    required this.food,
    required this.date,
    required this.quantity,
  });

  double get subtotal => food.price * quantity;

  Order copyWith({
    Restaurant? restaurant,
    Food? food,
    String? date,
    int? quantity,
  }) {
    return Order(
      restaurant: restaurant ?? this.restaurant,
      food: food ?? this.food,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
    );
  }
}
