import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/order.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';
import 'package:pos/features/cart/presentation/widgets/merchant_conflict_dialog.dart';
import 'package:pos/features/discovery/data/restaurant_repository.dart';

class RecentOrders extends ConsumerWidget {
  final VoidCallback? onOrderAdded;

  const RecentOrders({super.key, this.onOrderAdded});

  Widget _buildRecentOrder(BuildContext context, WidgetRef ref, Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      width: 320.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          width: 1.0,
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image(
                    height: 100.0,
                    width: 100.0,
                    image: AssetImage(order.food.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          order.food.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          order.restaurant.name,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          order.date,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20.0),
            width: 48.0,
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

                final success = cartController.addItem(order.food, order.restaurant);
                if (!success && context.mounted) {
                  final shouldClear = await showSingleMerchantConflictDialog(
                    context,
                    currentMerchant: cartState.currentRestaurant?.name ?? 'another restaurant',
                    newMerchant: order.restaurant.name,
                  );
                  if (shouldClear) {
                    cartController.forceAddItem(order.food, order.restaurant);
                    onOrderAdded?.call();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Started new order with ${order.food.name}!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                } else {
                  onOrderAdded?.call();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${order.food.name} to cart!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentOrders = ref.watch(recentOrdersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 125.0,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 10.0),
              scrollDirection: Axis.horizontal,
              itemCount: recentOrders.length,
              itemBuilder: (BuildContext context, int index) {
                Order order = recentOrders[index];
                return _buildRecentOrder(context, ref, order);
              },
            ),
          ),
        ),
      ],
    );
  }
}
