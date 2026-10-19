import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/cart/domain/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final Restaurant? currentRestaurant;

  const CartState({
    this.items = const [],
    this.currentRestaurant,
  });

  double get subtotal =>
      items.fold(0.0, (previousValue, item) => previousValue + item.subtotal);

  int get itemCount =>
      items.fold(0, (previousValue, item) => previousValue + item.quantity);

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    Restaurant? Function()? currentRestaurant,
  }) {
    return CartState(
      items: items ?? this.items,
      currentRestaurant: currentRestaurant != null
          ? currentRestaurant()
          : this.currentRestaurant,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          currentRestaurant == other.currentRestaurant;

  @override
  int get hashCode => items.hashCode ^ currentRestaurant.hashCode;
}
