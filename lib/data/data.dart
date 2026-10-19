import 'package:pos/models/food.dart';
import 'package:pos/models/order.dart';
import 'package:pos/models/restaurant.dart';
import 'package:pos/models/user.dart';

// Realistic Artisanal Dishes
const _burrito = Food(
  imageUrl: 'assets/images/burrito.jpg',
  name: 'Cali Carne Asada Burrito',
  price: 13.99,
);
const _steak = Food(
  imageUrl: 'assets/images/steak.jpg',
  name: 'Dry-Aged Prime Ribeye',
  price: 34.99,
);
const _pasta = Food(
  imageUrl: 'assets/images/pasta.jpg',
  name: 'Truffle Tagliatelle Carbonara',
  price: 19.99,
);
const _ramen = Food(
  imageUrl: 'assets/images/ramen.jpg',
  name: 'Tokyo Tonkotsu Black Garlic Ramen',
  price: 16.99,
);
const _pancakes = Food(
  imageUrl: 'assets/images/pancakes.jpg',
  name: 'Blueberry Ricotta Hotcakes',
  price: 12.99,
);
const _burger = Food(
  imageUrl: 'assets/images/burger.jpg',
  name: 'Truffle Wagyu Bacon Burger',
  price: 17.99,
);
const _pizza = Food(
  imageUrl: 'assets/images/pizza.jpg',
  name: 'San Marzano Margherita D.O.P.',
  price: 16.49,
);
const _salmon = Food(
  imageUrl: 'assets/images/salmon.jpg',
  name: 'Miso-Glazed Atlantic Salmon Bowl',
  price: 21.99,
);
const _bubbleTea = Food(
  imageUrl: 'assets/images/bubble_tea.jpg',
  name: 'Brown Sugar Boba Bubble Tea',
  price: 6.99,
);
const _beefNoodleSoup = Food(
  imageUrl: 'assets/images/beef_noodle_soup.jpg',
  name: 'Taipei Slice Beef Rice Noodle Soup',
  price: 18.99,
);
const _dumplings = Food(
  imageUrl: 'assets/images/dumplings.jpg',
  name: 'Dumplings',
  price: 14.50,
);

// Realistic Culinary Establishments & Locations
const _restaurant0 = Restaurant(
  imageUrl: 'assets/images/restaurant0.jpg',
  name: 'The Rustic Table Bistro',
  address: '142 Mercer St, SoHo, NY 10012',
  rating: 5,
  distance: '0.3 miles away',
  latitude: 40.7250,
  longitude: -73.9984,
  menu: [_burger, _steak, _pasta, _ramen, _pancakes, _burrito, _pizza, _salmon],
);

const _restaurant5 = Restaurant(
  imageUrl: 'assets/images/restaurant5.jpg',
  name: 'Formosa Imperial Teahouse',
  address: '38 Doyers St, Chinatown, NY 10013',
  rating: 5,
  distance: '0.4 miles away',
  latitude: 40.7144,
  longitude: -73.9980,
  menu: [_beefNoodleSoup, _dumplings, _bubbleTea, _ramen],
);

const _restaurant1 = Restaurant(
  imageUrl: 'assets/images/restaurant1.jpg',
  name: 'Bella Notte Trattoria',
  address: '88 Mulberry St, Little Italy, NY 10013',
  rating: 5,
  distance: '0.6 miles away',
  latitude: 40.7165,
  longitude: -73.9986,
  menu: [_pasta, _pizza, _steak, _salmon],
);

const _restaurant2 = Restaurant(
  imageUrl: 'assets/images/restaurant2.jpg',
  name: 'Prime & Ember Steakhouse',
  address: '350 Hudson St, Tribeca, NY 10014',
  rating: 4,
  distance: '1.1 miles away',
  latitude: 40.7275,
  longitude: -74.0076,
  menu: [_steak, _burger, _salmon, _pasta],
);

const _restaurant3 = Restaurant(
  imageUrl: 'assets/images/restaurant3.jpg',
  name: 'Taquería El Sol Mexican Grill',
  address: '1612 Emmons Ave, Sheepshead Bay, NY 11235',
  rating: 4,
  distance: '9.3 miles away',
  latitude: 40.5842,
  longitude: -73.9515,
  menu: [_burrito, _steak, _burger],
);

const _restaurant4 = Restaurant(
  imageUrl: 'assets/images/restaurant4.jpg',
  name: 'Hakata Artisan Ramen & Brunch',
  address: '52 Kenmare St, Nolita, NY 10012',
  rating: 5,
  distance: '2.4 miles away',
  latitude: 40.7208,
  longitude: -73.9961,
  menu: [_ramen, _pancakes, _salmon, _burrito],
);

final List<Restaurant> restaurants = [
  _restaurant0,
  _restaurant5,
  _restaurant1,
  _restaurant2,
  _restaurant3,
  _restaurant4,
];

// Active User Profile
final currentUser = User(
  name: 'Rebecca',
  orders: [
    Order(
      date: 'Oct 17, 2026',
      food: _beefNoodleSoup,
      restaurant: _restaurant5,
      quantity: 1,
    ),
    Order(
      date: 'Oct 16, 2026',
      food: _steak,
      restaurant: _restaurant2,
      quantity: 1,
    ),
    Order(
      date: 'Oct 14, 2026',
      food: _ramen,
      restaurant: _restaurant4,
      quantity: 2,
    ),
    Order(
      date: 'Oct 11, 2026',
      food: _burrito,
      restaurant: _restaurant3,
      quantity: 2,
    ),
    Order(
      date: 'Oct 07, 2026',
      food: _salmon,
      restaurant: _restaurant0,
      quantity: 1,
    ),
    Order(
      date: 'Oct 03, 2026',
      food: _pancakes,
      restaurant: _restaurant4,
      quantity: 3,
    ),
  ],
  cart: [
    Order(
      date: 'Oct 18, 2026',
      food: _burger,
      restaurant: _restaurant0,
      quantity: 2,
    ),
    Order(
      date: 'Oct 18, 2026',
      food: _pasta,
      restaurant: _restaurant0,
      quantity: 1,
    ),
    Order(
      date: 'Oct 18, 2026',
      food: _pizza,
      restaurant: _restaurant0,
      quantity: 1,
    ),
  ],
);
