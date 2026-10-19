import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/core/services/location_service.dart';
import 'package:pos/core/widgets/rating_stars.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';
import 'package:pos/features/cart/presentation/cart_screen.dart';
import 'package:pos/features/discovery/data/restaurant_repository.dart';
import 'package:pos/features/discovery/presentation/widgets/recent_orders.dart';
import 'package:pos/features/restaurant/presentation/restaurant_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRestaurants(List<Restaurant> restaurants) {
    List<Widget> restaurantList = [];
    for (Restaurant restaurant in restaurants) {
      restaurantList.add(
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantScreen(restaurant: restaurant),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                width: 1.0,
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Hero(
                    tag: restaurant.imageUrl,
                    child: Image(
                      height: 150.0,
                      width: 150.0,
                      image: AssetImage(restaurant.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        RatingStars(restaurant.rating),
                        const SizedBox(height: 4.0),
                        Text(
                          restaurant.address,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          restaurant.distance,
                          style: const TextStyle(
                            fontSize: 16.0,
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
        ),
      );
    }
    return Column(children: restaurantList);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final repo = ref.watch(restaurantRepositoryProvider);
    final locationService = ref.watch(locationServiceProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    final userLoc = userLocationAsync.asData?.value ?? UserLocation.defaultLocation;

    final displayedRestaurants = _searchQuery.isEmpty
        ? ref.watch(nearbyRestaurantsWithDistanceProvider)
        : locationService.annotateAndSortRestaurants(repo.searchRestaurants(_searchQuery), userLoc);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          iconSize: 30.0,
          color: Colors.white,
          onPressed: () {},
        ),
        title: const Text(
          'Stream Works',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cart (${cartState.itemCount})',
              style: const TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                fillColor: Colors.white70,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(
                    width: 0.8,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                hintText: 'Search Food or Restaurants',
                prefixIcon: const Icon(
                  Icons.search,
                  size: 30.0,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),
          const RecentOrders(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Nearby Restaurants',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildRestaurants(displayedRestaurants),
            ],
          ),
        ],
      ),
    );
  }
}
