import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/order.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/data/data.dart' as legacy_data;
import 'package:pos/features/cart/domain/cart_item.dart';
import 'package:pos/features/cart/domain/cart_state.dart';

class CartController extends Notifier<CartState> {
  final CartState? _initialState;

  CartController([this._initialState]);

  @override
  CartState build() {
    return _initialState ?? const CartState();
  }

  void _syncLegacyStore() {
    legacy_data.currentUser.cart.clear();
    for (final item in state.items) {
      legacy_data.currentUser.cart.add(
        Order(
          restaurant: item.restaurant,
          food: item.food,
          date: 'Today',
          quantity: item.quantity,
        ),
      );
    }
  }

  /// Adds a food item to the cart.
  /// Enforces Single-Merchant Cart Policy (BR-01):
  /// Returns `false` if an item from a different restaurant is attempted while
  /// items already exist from another restaurant.
  bool addItem(Food food, Restaurant restaurant) {
    if (state.items.isNotEmpty &&
        state.currentRestaurant != null &&
        state.currentRestaurant!.name != restaurant.name) {
      return false;
    }

    final existingIndex = state.items.indexWhere(
      (item) => item.food.name == food.name && item.restaurant.name == restaurant.name,
    );

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      final existingItem = state.items[existingIndex];
      // Bound at 99 (BR-02)
      final newQuantity = (existingItem.quantity + 1).clamp(1, 99);
      final updatedItem = existingItem.copyWith(quantity: newQuantity);

      updatedItems = List.from(state.items);
      updatedItems[existingIndex] = updatedItem;
    } else {
      updatedItems = [...state.items, CartItem(food: food, restaurant: restaurant, quantity: 1)];
    }

    state = state.copyWith(
      items: updatedItems,
      currentRestaurant: () => restaurant,
    );
    _syncLegacyStore();
    return true;
  }

  /// Overrides single-merchant conflict by clearing the existing cart and
  /// initiating a new cart with the selected restaurant and food item.
  void forceAddItem(Food food, Restaurant restaurant) {
    state = CartState(
      items: [CartItem(food: food, restaurant: restaurant, quantity: 1)],
      currentRestaurant: restaurant,
    );
    _syncLegacyStore();
  }

  /// Increments quantity for a cart line item, capped at 99 (BR-02).
  void incrementQuantity(CartItem item) {
    final index = state.items.indexOf(item);
    if (index < 0) return;

    if (item.quantity >= 99) return;

    final updatedItem = item.copyWith(quantity: item.quantity + 1);
    final updatedList = List<CartItem>.from(state.items);
    updatedList[index] = updatedItem;

    state = state.copyWith(items: updatedList);
    _syncLegacyStore();
  }

  /// Decrements quantity for a cart line item.
  /// If quantity reaches 0, removes the item from the cart (BR-02).
  void decrementQuantity(CartItem item) {
    final index = state.items.indexOf(item);
    if (index < 0) return;

    if (item.quantity <= 1) {
      removeItem(item);
      return;
    }

    final updatedItem = item.copyWith(quantity: item.quantity - 1);
    final updatedList = List<CartItem>.from(state.items);
    updatedList[index] = updatedItem;

    state = state.copyWith(items: updatedList);
    _syncLegacyStore();
  }

  /// Removes a specific line item from the cart.
  void removeItem(CartItem item) {
    final updatedList = state.items.where((element) => element != item).toList();
    state = state.copyWith(
      items: updatedList,
      currentRestaurant: () => updatedList.isEmpty ? null : state.currentRestaurant,
    );
    _syncLegacyStore();
  }

  /// Clears all cart items and resets the merchant association.
  void clearCart() {
    state = const CartState();
    _syncLegacyStore();
  }
}

/// Global provider for reactive CartController state management.
final cartProvider = NotifierProvider<CartController, CartState>(CartController.new);
