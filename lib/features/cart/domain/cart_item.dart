import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';

class CartItem {
  final Food food;
  final Restaurant restaurant;
  final int quantity;

  const CartItem({
    required this.food,
    required this.restaurant,
    this.quantity = 1,
  });

  double get subtotal => food.price * quantity;

  CartItem copyWith({
    Food? food,
    Restaurant? restaurant,
    int? quantity,
  }) {
    return CartItem(
      food: food ?? this.food,
      restaurant: restaurant ?? this.restaurant,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          food == other.food &&
          restaurant == other.restaurant &&
          quantity == other.quantity;

  @override
  int get hashCode => food.hashCode ^ restaurant.hashCode ^ quantity.hashCode;
}
