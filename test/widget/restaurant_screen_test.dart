import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/features/restaurant/presentation/widgets/restaurant_contact_modal.dart';
import 'package:pos/features/restaurant/presentation/widgets/restaurant_reviews_modal.dart';

void main() {
  const food = Food(
    name: 'Sample Dumplings',
    imageUrl: 'assets/images/dumplings.jpg',
    price: 14.50,
  );

  const restaurant = Restaurant(
    imageUrl: 'assets/images/restaurant5.jpg',
    name: 'Formosa Imperial Teahouse',
    address: '38 Doyers St, Chinatown, NY 10013',
    rating: 5,
    menu: [food],
    distance: '0.4 miles away',
  );

  testWidgets('RestaurantReviewsModal displays ratings, breakdown, and verified reviews', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.deepOrangeAccent,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        ),
        home: const Scaffold(
          body: RestaurantReviewsModal(restaurant: restaurant),
        ),
      ),
    );

    // Verify modal elements are rendered
    expect(find.text('Reviews & Ratings'), findsOneWidget);
    expect(find.text('Write a Review'), findsOneWidget);
    expect(find.text('Formosa Imperial Teahouse'), findsOneWidget);
    expect(find.text('5.0'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsWidgets);
    expect(find.textContaining('Outstanding quality!'), findsOneWidget);

    // Tap Write a Review button to open feedback dialog
    await tester.tap(find.text('Write a Review'));
    await tester.pumpAndSettle();

    expect(find.text('Rating for Formosa Imperial Teahouse'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);
  });

  testWidgets('RestaurantContactModal displays merchant details, phone, address, and hours', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.deepOrangeAccent,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        ),
        home: const Scaffold(
          body: RestaurantContactModal(restaurant: restaurant),
        ),
      ),
    );

    // Verify contact modal elements
    expect(find.text('Merchant Contact & Info'), findsOneWidget);
    expect(find.text('Formosa Imperial Teahouse'), findsOneWidget);
    expect(find.text('Open Now'), findsOneWidget);
    expect(find.text('0.4 miles away'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Location & Address'), findsOneWidget);
    expect(find.text('38 Doyers St, Chinatown, NY 10013'), findsOneWidget);

    // Scroll to reveal hours and action buttons
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Hours of Operation'), findsOneWidget);
    expect(find.text('Monday – Thursday'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Send Message to Merchant'),
      50.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Send Message to Merchant'), findsOneWidget);

    // Tap Send Message to open inquiry dialog
    await tester.tap(find.text('Send Message to Merchant'));
    await tester.pumpAndSettle();

    expect(find.text('Contact Merchant'), findsOneWidget);
    expect(find.text('Send a message to Formosa Imperial Teahouse:'), findsOneWidget);
  });

  testWidgets('showRestaurantReviewsModal and showRestaurantContactModal open via action triggers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.deepOrangeAccent,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => showRestaurantReviewsModal(context, restaurant),
                  child: const Text('Open Reviews'),
                ),
                ElevatedButton(
                  onPressed: () => showRestaurantContactModal(context, restaurant),
                  child: const Text('Open Contact'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Trigger Reviews Modal
    await tester.tap(find.text('Open Reviews'));
    await tester.pumpAndSettle();
    expect(find.byType(RestaurantReviewsModal), findsOneWidget);

    // Close modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(RestaurantReviewsModal), findsNothing);

    // Trigger Contact Modal
    await tester.tap(find.text('Open Contact'));
    await tester.pumpAndSettle();
    expect(find.byType(RestaurantContactModal), findsOneWidget);
  });
}
