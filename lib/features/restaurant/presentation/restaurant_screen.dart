import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/core/widgets/rating_stars.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';
import 'package:pos/features/cart/presentation/cart_screen.dart';
import 'package:pos/features/cart/presentation/widgets/merchant_conflict_dialog.dart';
import 'package:pos/features/restaurant/presentation/widgets/restaurant_contact_modal.dart';
import 'package:pos/features/restaurant/presentation/widgets/restaurant_reviews_modal.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const RestaurantScreen({super.key, required this.restaurant});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  Widget _buildMenuItem(Food menuItem) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 175.0,
            width: 175.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(menuItem.imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          Container(
            height: 175.0,
            width: 175.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black87.withValues(alpha: 0.3),
                  Colors.black54.withValues(alpha: 0.3),
                  Colors.black38.withValues(alpha: 0.3),
                ],
                stops: const [0.1, 0.4, 0.6, 0.9],
              ),
            ),
          ),
          Positioned(
            bottom: 65.0,
            child: Column(
              children: <Widget>[
                Text(
                  menuItem.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '\$${menuItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                iconSize: 30.0,
                color: Colors.white,
                onPressed: () async {
                  final cartController = ref.read(cartProvider.notifier);
                  final cartState = ref.read(cartProvider);

                  final success = cartController.addItem(menuItem, widget.restaurant);
                  if (!success && mounted) {
                    final shouldClear = await showSingleMerchantConflictDialog(
                      context,
                      currentMerchant: cartState.currentRestaurant?.name ?? 'another restaurant',
                      newMerchant: widget.restaurant.name,
                    );
                    if (shouldClear) {
                      cartController.forceAddItem(menuItem, widget.restaurant);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Started new order with ${menuItem.name}!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${menuItem.name} to cart!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Hero(
                tag: widget.restaurant.imageUrl,
                child: Image(
                  height: 220.0,
                  width: MediaQuery.of(context).size.width,
                  image: AssetImage(widget.restaurant.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      color: Theme.of(context).primaryColor,
                      iconSize: 35.0,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.restaurant.distance,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
                RatingStars(widget.restaurant.rating),
                const SizedBox(height: 6.0),
                Text(
                  widget.restaurant.address,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Reviews',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  showRestaurantReviewsModal(context, widget.restaurant);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Contact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  showRestaurantContactModal(context, widget.restaurant);
                },
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          const Center(
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(10.0),
              crossAxisCount: 2,
              children: List.generate(widget.restaurant.menu.length, (index) {
                Food food = widget.restaurant.menu[index];
                return _buildMenuItem(food);
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.shopping_cart),
        label: Text('Cart (${cartState.itemCount})'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
      ),
    );
  }
}
