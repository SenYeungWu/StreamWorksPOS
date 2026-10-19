import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/cart/presentation/cart_screen.dart';
import 'package:pos/features/discovery/presentation/home_screen.dart';
import 'package:pos/features/restaurant/presentation/restaurant_screen.dart';
import 'package:pos/features/tracking/presentation/courier_tracking_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (BuildContext context, GoRouterState state) => const CartScreen(),
    ),
    GoRoute(
      path: '/restaurant',
      name: 'restaurant',
      builder: (BuildContext context, GoRouterState state) {
        final restaurant = state.extra as Restaurant;
        return RestaurantScreen(restaurant: restaurant);
      },
    ),
    GoRoute(
      path: '/tracking',
      name: 'tracking',
      builder: (BuildContext context, GoRouterState state) => const CourierTrackingScreen(),
    ),
  ],
);
