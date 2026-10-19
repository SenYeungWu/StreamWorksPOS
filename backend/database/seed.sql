-- =============================================================================
-- Stream Works Seed Data (Realistic Artisanal Establishments & Coordinates)
-- =============================================================================

-- Clear existing data
TRUNCATE order_items, orders, menu_items, restaurants, users RESTART IDENTITY CASCADE;

-- Insert Customer
INSERT INTO users (id, name, email) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Rebecca', 'rebecca@streamworks.app');

-- Insert Restaurants with PostGIS coordinates
-- Point format: ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
INSERT INTO restaurants (id, name, image_url, address, rating, location) VALUES
('b1111111-1111-1111-1111-111111111111', 'The Rustic Table Bistro', 'assets/images/restaurant0.jpg', '142 Mercer St, SoHo, NY 10012', 5, ST_SetSRID(ST_MakePoint(-73.9984, 40.7250), 4326)),
('b6666666-6666-6666-6666-666666666666', 'Formosa Imperial Teahouse', 'assets/images/restaurant5.jpg', '38 Doyers St, Chinatown, NY 10013', 5, ST_SetSRID(ST_MakePoint(-73.9980, 40.7144), 4326)),
('b2222222-2222-2222-2222-222222222222', 'Bella Notte Trattoria', 'assets/images/restaurant1.jpg', '88 Mulberry St, Little Italy, NY 10013', 5, ST_SetSRID(ST_MakePoint(-73.9986, 40.7165), 4326)),
('b3333333-3333-3333-3333-333333333333', 'Prime & Ember Steakhouse', 'assets/images/restaurant2.jpg', '350 Hudson St, Tribeca, NY 10014', 4, ST_SetSRID(ST_MakePoint(-74.0076, 40.7275), 4326)),
('b4444444-4444-4444-4444-444444444444', 'Taquería El Sol Mexican Grill', 'assets/images/restaurant3.jpg', '1612 Emmons Ave, Sheepshead Bay, NY 11235', 4, ST_SetSRID(ST_MakePoint(-73.9515, 40.5842), 4326)),
('b5555555-5555-5555-5555-555555555555', 'Hakata Artisan Ramen & Brunch', 'assets/images/restaurant4.jpg', '52 Kenmare St, Nolita, NY 10012', 5, ST_SetSRID(ST_MakePoint(-73.9961, 40.7208), 4326));

-- Insert Menu Items
-- Formosa Imperial Teahouse Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b6666666-6666-6666-6666-666666666666', 'Taipei Slice Beef Rice Noodle Soup', 'assets/images/beef_noodle_soup.jpg', 18.99),
('b6666666-6666-6666-6666-666666666666', 'Dumplings', 'assets/images/dumplings.jpg', 14.50),
('b6666666-6666-6666-6666-666666666666', 'Tokyo Tonkotsu Black Garlic Ramen', 'assets/images/ramen.jpg', 16.99),
('b6666666-6666-6666-6666-666666666666', 'Brown Sugar Boba Bubble Tea', 'assets/images/bubble_tea.jpg', 6.99);

-- Insert Menu Items
-- The Rustic Table Bistro Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b1111111-1111-1111-1111-111111111111', 'Truffle Wagyu Bacon Burger', 'assets/images/burger.jpg', 17.99),
('b1111111-1111-1111-1111-111111111111', 'Dry-Aged Prime Ribeye', 'assets/images/steak.jpg', 34.99),
('b1111111-1111-1111-1111-111111111111', 'Truffle Tagliatelle Carbonara', 'assets/images/pasta.jpg', 19.99),
('b1111111-1111-1111-1111-111111111111', 'Tokyo Tonkotsu Black Garlic Ramen', 'assets/images/ramen.jpg', 16.99),
('b1111111-1111-1111-1111-111111111111', 'Blueberry Ricotta Hotcakes', 'assets/images/pancakes.jpg', 12.99),
('b1111111-1111-1111-1111-111111111111', 'Cali Carne Asada Burrito', 'assets/images/burrito.jpg', 13.99),
('b1111111-1111-1111-1111-111111111111', 'San Marzano Margherita D.O.P.', 'assets/images/pizza.jpg', 16.49),
('b1111111-1111-1111-1111-111111111111', 'Miso-Glazed Atlantic Salmon Bowl', 'assets/images/salmon.jpg', 21.99);

-- Bella Notte Trattoria Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b2222222-2222-2222-2222-222222222222', 'Truffle Tagliatelle Carbonara', 'assets/images/pasta.jpg', 19.99),
('b2222222-2222-2222-2222-222222222222', 'San Marzano Margherita D.O.P.', 'assets/images/pizza.jpg', 16.49),
('b2222222-2222-2222-2222-222222222222', 'Dry-Aged Prime Ribeye', 'assets/images/steak.jpg', 34.99),
('b2222222-2222-2222-2222-222222222222', 'Miso-Glazed Atlantic Salmon Bowl', 'assets/images/salmon.jpg', 21.99);

-- Prime & Ember Steakhouse Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b3333333-3333-3333-3333-333333333333', 'Dry-Aged Prime Ribeye', 'assets/images/steak.jpg', 34.99),
('b3333333-3333-3333-3333-333333333333', 'Truffle Wagyu Bacon Burger', 'assets/images/burger.jpg', 17.99),
('b3333333-3333-3333-3333-333333333333', 'Miso-Glazed Atlantic Salmon Bowl', 'assets/images/salmon.jpg', 21.99),
('b3333333-3333-3333-3333-333333333333', 'Truffle Tagliatelle Carbonara', 'assets/images/pasta.jpg', 19.99);

-- Taquería El Sol Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b4444444-4444-4444-4444-444444444444', 'Cali Carne Asada Burrito', 'assets/images/burrito.jpg', 13.99),
('b4444444-4444-4444-4444-444444444444', 'Dry-Aged Prime Ribeye', 'assets/images/steak.jpg', 34.99),
('b4444444-4444-4444-4444-444444444444', 'Truffle Wagyu Bacon Burger', 'assets/images/burger.jpg', 17.99);

-- Hakata Artisan Ramen Menu
INSERT INTO menu_items (restaurant_id, name, image_url, price) VALUES
('b5555555-5555-5555-5555-555555555555', 'Tokyo Tonkotsu Black Garlic Ramen', 'assets/images/ramen.jpg', 16.99),
('b5555555-5555-5555-5555-555555555555', 'Blueberry Ricotta Hotcakes', 'assets/images/pancakes.jpg', 12.99),
('b5555555-5555-5555-5555-555555555555', 'Miso-Glazed Atlantic Salmon Bowl', 'assets/images/salmon.jpg', 21.99),
('b5555555-5555-5555-5555-555555555555', 'Cali Carne Asada Burrito', 'assets/images/burrito.jpg', 13.99);
