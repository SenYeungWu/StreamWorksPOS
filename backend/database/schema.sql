-- =============================================================================
-- Stream Works Database Schema (PostgreSQL 16 + PostGIS Spatial Engine)
-- Business Rules: BR-01, BR-02, BR-04
-- =============================================================================

-- Enable PostGIS spatial extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Clean previous instances if needed
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- -----------------------------------------------------------------------------
-- 1. Restaurants Table (with PostGIS Geometry Point & GiST Index)
-- -----------------------------------------------------------------------------
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    location GEOMETRY(Point, 4326) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial GiST Index for sub-millisecond proximity queries (TASK-4.1)
CREATE INDEX idx_restaurants_location ON restaurants USING GIST(location);
CREATE INDEX idx_restaurants_active ON restaurants(is_active);

-- -----------------------------------------------------------------------------
-- 2. Menu Items Table
-- -----------------------------------------------------------------------------
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0.00),
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);

-- -----------------------------------------------------------------------------
-- 3. Users Table
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 4. Orders Table (Enforcing Single-Merchant BR-01)
-- -----------------------------------------------------------------------------
CREATE TYPE order_status AS ENUM (
    'ORDER_PLACED',
    'PREPARING',
    'PICKED_UP',
    'DELIVERED',
    'CANCELLED'
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE RESTRICT,
    status order_status NOT NULL DEFAULT 'ORDER_PLACED',
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0.00),
    delivery_latitude DOUBLE PRECISION,
    delivery_longitude DOUBLE PRECISION,
    courier_latitude DOUBLE PRECISION,
    courier_longitude DOUBLE PRECISION,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_status ON orders(status);

-- -----------------------------------------------------------------------------
-- 5. Order Items Table (Enforcing Quantity Bounds 1-99 BR-02)
-- -----------------------------------------------------------------------------
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity >= 1 AND quantity <= 99),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0.00),
    subtotal NUMERIC(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE INDEX idx_order_items_order ON order_items(order_id);

-- -----------------------------------------------------------------------------
-- 6. Geospatial Stored Procedure: get_nearby_restaurants (TASK-4.2)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_nearby_restaurants(
    user_lat DOUBLE PRECISION,
    user_lng DOUBLE PRECISION,
    radius_meters DOUBLE PRECISION DEFAULT 10000.0
)
RETURNS TABLE (
    id UUID,
    name VARCHAR(150),
    image_url VARCHAR(255),
    address VARCHAR(255),
    rating INTEGER,
    distance_meters DOUBLE PRECISION,
    distance_miles DOUBLE PRECISION,
    estimated_eta_minutes INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.name,
        r.image_url,
        r.address,
        r.rating,
        ST_Distance(
            r.location::geography,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) AS distance_meters,
        ST_Distance(
            r.location::geography,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) * 0.000621371 AS distance_miles,
        -- BR-04: ETA = 15m (prep) + (distance_miles * 5m) + 5m (buffer)
        ROUND(15 + (ST_Distance(
            r.location::geography,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) * 0.000621371 * 5) + 5)::INTEGER AS estimated_eta_minutes
    FROM
        restaurants r
    WHERE
        r.is_active = TRUE
        AND ST_DWithin(
            r.location::geography,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
            radius_meters
        )
    ORDER BY
        distance_meters ASC;
END;
$$ LANGUAGE plpgsql;
