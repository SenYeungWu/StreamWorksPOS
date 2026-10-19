# Stream Works — User & Testing Guide

Welcome to **Stream Works** (formerly Meal Express), an artisanal food discovery and ordering mobile and web platform built with Flutter, Riverpod, and Clean Architecture.

This guide provides instructions for accessing the application, running manual testing workflows, and validating core business requirements implemented across all project phases (Phases 1–5).

---

## 1. Accessing the Application

The Stream Works web interface can be accessed across modern web browsers (Chrome, Edge, Safari, Firefox) on desktop and mobile devices.

### 1.1 Live Development Server URLs

| Environment | Access URL | Target Audience |
| :--- | :--- | :--- |
| **Local Host** | [http://localhost:8085](http://localhost:8085) | Testing directly on this workstation |
| **Local Network (LAN)** | `http://192.168.86.236:8085` | Testing on mobile phones, tablets, or other PCs on the same Wi-Fi |

> [!NOTE]
> If your workstation's IP address changes or you switch Wi-Fi networks, run `ipconfig` (Windows) or `ifconfig` (macOS/Linux) to find your current IPv4 address, and access port `8085`.

### 1.2 Starting the Server Manually

To start or restart the local development web server:

```powershell
$env:Path = "C:\flutter\bin;" + $env:Path
flutter run -d web-server --web-port 8085 --web-hostname 0.0.0.0
```

---

## 2. Core Features & Manual Testing Scenarios

Use the following step-by-step test scenarios to validate the implementation of Phases 1 through 3.

---

### Scenario 1: Discovery & Instant Search

**Objective**: Verify restaurant discovery, menu listings, and live search filtering.

1. **Open the Home Screen**:
   - Navigate to [http://localhost:8085](http://localhost:8085).
   - Observe the **Stream Works** top AppBar, the search input field, the **Recent Orders** carousel, and the **Nearby Restaurants** list.
2. **Test Live Search by Dish**:
   - Tap into the **Search Food or Restaurants** field.
   - Type `Burrito` or `Truffle`.
   - **Expected Result**: The restaurant list instantly updates in real-time to show only establishments offering that dish.
3. **Test Live Search by Restaurant Name**:
   - Clear the search and type `Bella` or `Rustic`.
   - **Expected Result**: Only matching restaurants are displayed.
4. **Clear Search**:
   - Click the `X` (clear) icon inside the search bar.
   - **Expected Result**: All 5 restaurants reappear in the list.

---

### Scenario 2: Reactive Cart Counter & Empty State

**Objective**: Verify initial reactive cart state and empty cart UX.

1. **Verify Initial Badge**:
   - On a freshly launched session, look at the top-right button in the AppBar.
   - **Expected Result**: The badge displays `Cart (0)`.
2. **Open Empty Cart**:
   - Click the `Cart (0)` button.
   - **Expected Result**: The cart screen opens, displaying the message: `"Your cart is empty"`.
   - No checkout button or broken price totals should be displayed.

---

### Scenario 3: Single-Merchant Cart Policy (Business Rule BR-01)

**Objective**: Confirm that a customer can only hold items from one restaurant at a time and is prompted before clearing an existing cart.

1. **Add First Restaurant's Dish**:
   - On the Home screen, tap on **The Rustic Table Bistro** to open its menu.
   - Tap the `+` icon on **Truffle Wagyu Bacon Burger** ($17.99).
   - Observe the confirmation SnackBar: *"Added Truffle Wagyu Bacon Burger to cart!"*.
   - Return to the Home screen or look at the AppBar: the cart button now shows `Cart (1)`.
2. **Attempt Adding from a Different Restaurant**:
   - Return to the Home screen and scroll to **Recent Orders**.
   - Tap the `+` button on **Blueberry Ricotta Hotcakes** (from *Hakata Artisan Ramen & Brunch*).
   - Alternatively, open **Bella Notte Trattoria** and tap `+` on any pasta or pizza dish.
3. **Validate Merchant Conflict Dialog**:
   - **Expected Result**: The **Merchant Conflict Dialog** modal appears with the title **"Replace Cart Items?"**:
     > *"Your cart already contains items from The Rustic Table Bistro. Would you like to clear your cart and start a new order with Hakata Artisan Ramen & Brunch?"*
4. **Test "Cancel" Option**:
   - Tap **Cancel**.
   - **Expected Result**: The dialog closes. The cart retains the original burger from *The Rustic Table Bistro*, and the new item is not added.
5. **Test "Start New Order" Option**:
   - Tap `+` again on the second restaurant's dish.
   - In the conflict dialog, tap **Start New Order**.
   - **Expected Result**: The dialog closes, the old cart is cleared, and the new item is added. A SnackBar confirms: *"Started new order with Blueberry Ricotta Hotcakes!"*.

---

### Scenario 4: Quantity Controls & Bounds (Business Rule BR-02)

**Objective**: Validate real-time line-item subtotal calculation, upper bound capping (99), and automatic removal when reaching 0.

1. **Open the Active Cart**:
   - Tap `Cart (N)` in the top AppBar to navigate to the cart screen.
2. **Increment Quantity**:
   - Tap the `+` button next to a dish.
   - **Expected Result**:
     - Quantity increments from `1` to `2`.
     - The line-item price multiplies proportionally (e.g., $10.00 becomes $20.00).
     - The **Total Cost** at the bottom updates immediately.
3. **Upper Bound Capping (99)**:
   - Repeatedly incrementing or testing up to 99 will cap the line item at 99 without throwing exceptions or overflowing layout containers.
4. **Decrement Quantity & Auto-Removal**:
   - Tap the `-` button to reduce quantity from `2` down to `1`.
   - Tap the `-` button once more when quantity is `1`.
   - **Expected Result**: The line item is completely removed from the cart. If no other items remain, the view transitions to the clean `"Your cart is empty"` screen and the restaurant association is cleared.

---

### Scenario 5: Checkout & Live Tracking Navigation

**Objective**: Verify order completion, state cleanup, and transition to live tracking.

1. Add one or more dishes to the cart.
2. Open the cart screen.
3. Verify the **Estimated Delivery Time** (`25 min`) and **Total Cost** display accurate calculations.
4. Tap the **CHECKOUT** button at the bottom of the screen.
5. **Expected Result**:
   - A confirmation SnackBar appears: *"Checkout successful! Total: $XX.XX"*.
   - The cart is emptied, and the application immediately transitions to the **Live Order Tracking Screen** (`/tracking`).

---

### Scenario 6: Live Courier Telemetry & Order Stepper (TASK-4.4 & TASK-4.5)

**Objective**: Validate real-time order lifecycle stages and GPS telemetry simulation.

1. **Observe the Live Tracking Header**:
   - The top banner displays the Order ID (`#SW-89421`), remaining ETA in minutes, and an active progress bar.
2. **Observe the GPS Route Card**:
   - The route card displays origin merchant, destination address, and real-time streaming courier GPS coordinates (`Courier Lat: 40.72XX, Lng: -73.99XX`).
3. **Follow the Delivery Progress Stepper**:
   - Watch the animated lifecycle stages progress dynamically:
     1. `Order Placed` (Restaurant received order)
     2. `Kitchen Preparing` (Chef crafting dishes)
     3. `Courier En Route` (Courier heading to you)
     4. `Delivered` (Order completed)
   - Completed steps show checkmarks and brand highlighting.

---

### Scenario 7: Dynamic GPS Distance & Proximity Sorting (TASK-4.3)

**Objective**: Validate real-time distance calculation from user coordinates.

1. On the Home screen, observe the distance labels underneath each merchant:
   - Each restaurant displays its real-time computed distance (e.g., `0.3 miles away`, `0.6 miles away`).
   - Restaurants are ordered from closest to furthest based on geodesic spatial calculation.
2. If your browser prompts for Location permission:
   - Granting permission will dynamically re-calculate distances and re-order the merchants relative to your device's actual GPS position.

---

### Scenario 8: Offline Caching & Network Dropout Resilience (TASK-4.6)

**Objective**: Verify that the application continues to serve cached restaurant listings and menus when connectivity is interrupted.

1. Open the application in Google Chrome or Microsoft Edge at [http://localhost:8085](http://localhost:8085).
2. Press `F12` to open the Developer Tools.
3. Switch to the **Network** tab.
4. Locate the network throttling dropdown (defaults to *No throttling*) and select **Offline**.
5. Return to the app and perform searches (e.g., search `Burrito`, `Truffle`, `Pizza`).
6. **Expected Result**:
   - The application does NOT crash or show broken network error screens.
   - The `CachedRestaurantRepository` seamlessly falls back to cached data, allowing menu browsing and search to remain fully responsive during network dropouts.
7. Switch the network throttling back to *No throttling*.

---

### Scenario 9: PostgreSQL 16 + PostGIS Spatial Engine & Docker Stack (TASK-4.1 & TASK-4.2)

**Objective**: Validate the backend relational spatial database and proximity stored procedure.

1. **Spin up the Database via Docker**:
   ```powershell
   cd backend
   docker compose up -d
   ```
2. **Verify Container Health**:
   ```powershell
   docker ps
   ```
   Confirm `streamworks-postgres` (`postgis/postgis:16-3.4`) and `streamworks-redis` are healthy.
3. **Execute the Proximity Stored Procedure**:
   Connect using `psql` or any database GUI tool (DBeaver, TablePlus, pgAdmin):
   - **Host**: `localhost:5432`
   - **Database**: `streamworks`
   - **User**: `streamworks_user`
   - **Password**: `streamworks_secure_password`

   Run the test spatial query from City Hall (`40.7128, -74.0060`) within a 10 km radius:
   ```sql
   SELECT * FROM get_nearby_restaurants(40.7128, -74.0060, 10000.0);
   ```
4. **Expected Result**:
   - Returns all 5 artisanal establishments ordered by sub-millisecond distance (`distance_meters`, `distance_miles`).
   - Computes dynamic delivery ETAs according to Business Rule **BR-04** ($15\text{m prep} + \text{miles} \times 5\text{m} + 5\text{m buffer}$).

---

### Scenario 10: Payment Processing, Webhook Reconciliation & Keychain Security (Phase 5)

**Objective**: Manually test and inspect the Stripe payment workflow, server-side HMAC webhook reconciliation, and secure token lifecycle.

#### 10.1 In-App Manual Payment Testing (Live in Browser)

1. **Add Dishes to Cart**:
   - Open the web app at [http://localhost:8085](http://localhost:8085).
   - Select any restaurant (e.g., *Artisanal Bistro*) and add one or two items to your cart.
2. **Open Cart & Launch Stripe Checkout**:
   - Tap the **Cart** icon in the app bar.
   - Verify the line items, quantities, and **Total Cost** (e.g., `$28.75`).
   - Tap the large orange **CHECKOUT** button at the bottom.
3. **Inspect the Stripe Checkout Bottom Sheet**:
   - A modal bottom sheet titled **Stripe Checkout** opens with a yellow **TEST MODE** badge.
   - **Total Due**: Displays the dollar amount (e.g., `$28.75`).
   - **Stripe Integer Cents**: Displays the exact integer cents (`2875 cents`) sent to Stripe to eliminate IEEE-754 floating point rounding errors.
   - **Card Fields**: Automatically populated with Stripe's standard test card number `4242 4242 4242 4242`, Expiry `12/28`, CVC `123`, and ZIP `90210`.
4. **Try the One-Tap Test Card Helpers**:
   - Tap **Test Card (Success: 4242)** to immediately reset standard test credentials.
   - Tap **3D Secure (3000)** (`4000 0027 6000 3184`) to simulate a 3D Secure / SCA challenged card.
5. **Process the Payment**:
   - Tap the purple **Pay with Stripe** button.
   - The button transitions to a spinner with *"Contacting Stripe Gateway..."*.
   - Upon confirmation, the modal dismisses automatically.
   - A floating green confirmation SnackBar appears at the bottom:
     `Stripe Payment Confirmed! Tx: pi_..._sim | Total: $XX.XX`
   - The cart is emptied, and the application immediately transitions to the **Live Order Tracking Screen** (`/tracking`).

#### 10.2 How to Set Up a Real Stripe Developer Account (Optional)

If you wish to connect your own live or sandbox Stripe account:

1. **Create a Free Stripe Account**:
   - Visit [https://dashboard.stripe.com/register](https://dashboard.stripe.com/register).
   - Once logged in, ensure the toggle in the top-left is set to **Test Mode**.
2. **Obtain API Keys**:
   - Navigate to **Developers** $\rightarrow$ **API Keys** ([https://dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys)).
   - Copy your **Publishable key** (`pk_test_...`).
   - Reveal and copy your **Secret key** (`sk_test_...`).
3. **Configure the Flutter Client**:
   - In [lib/core/services/payment_service.dart](lib/core/services/payment_service.dart), update the default publishable key:
     ```dart
     const PaymentService({
       this.isTestMode = true,
       this.publishableKey = 'pk_test_YOUR_STRIPE_KEY_HERE',
     });
     ```
4. **Configure the Backend Server**:
   - In [backend/server/webhook_reconciliation.js](backend/server/webhook_reconciliation.js), configure your Stripe webhook signing secret:
     ```bash
     export STRIPE_WEBHOOK_SECRET="whsec_YOUR_WEBHOOK_SIGNING_SECRET"
     ```
5. **Listen to Webhooks with the Stripe CLI**:
   - Install the Stripe CLI: [https://docs.stripe.com/stripe-cli](https://docs.stripe.com/stripe-cli).
   - Forward webhook events directly to your local backend server:
     ```powershell
     stripe login
     stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
     ```
   - Trigger simulated test events:
     ```powershell
     stripe trigger payment_intent.succeeded
     ```

#### 10.3 Manual Webhook Reconciliation Test

Execute the local cryptographic verification harness to validate signature verification and duplicate rejection without needing an external network connection:

```powershell
node backend/server/test_webhook.js
```

**Expected Result**:
- ✅ Valid HMAC-SHA256 signature verification matching `STRIPE_WEBHOOK_SECRET`.
- 🛡️ Tampered payload rejection with `HTTP 400 (Invalid signature)`.
- 🔁 Duplicate event idempotency prevention (`Skipping duplicate event evt_test_001`).

#### 10.4 Platform Keychain Security Test

Verify hardware-backed Keystore/Keychain persistence for auth tokens:

```powershell
$env:Path = "C:\flutter\bin;" + $env:Path
flutter test test/unit/secure_storage_test.dart
```

---

## 3. Automated Test Suite Execution

For regression testing, run the comprehensive unit and widget test suites directly from the terminal.

### 3.1 Running All Automated Tests

```powershell
$env:Path = "C:\flutter\bin;" + $env:Path
flutter test
```

**Expected Outcome**: 100% passing across all 35 automated tests:
- `test/unit/payment_service_test.dart`: Validates Stripe currency integer-cents conversions, formatting, and checkout transaction settlement.
- `test/unit/secure_storage_test.dart`: Validates platform keychain storage (iOS Keychain / Android KeyStore) for JWT tokens and logout teardown.
- `test/unit/location_service_test.dart`: Validates Haversine geodesic distance calculation, distance formatting, BR-04 ETA formula, and proximity sorting.
- `test/unit/telemetry_service_test.dart`: Validates real-time WebSocket order lifecycle stages, coordinates, and countdown calculations.
- `test/unit/cached_repository_test.dart`: Validates offline resilience and automatic fallback to memory cache during network dropouts (airplane mode).
- `test/unit/cart_controller_test.dart`: Validates Riverpod `CartController`, single-merchant conflict rejection (BR-01), force-add replacement, and quantity bounds 1–99 (BR-02).
- `test/unit/cart_test.dart`: Validates price calculations and line-item scaling.
- `test/unit/models_test.dart`: Validates sound null-safe domain models and immutability.
- `test/unit/restaurant_repository_test.dart`: Validates repository pattern discovery and search algorithms.
- `test/widget/cart_screen_test.dart`: Validates interactive quantity increments and subtotal re-rendering.
- `test/widget/clean_ui_test.dart`: Validates UI hygiene and absence of debug artifacts.
- `test/widget_test.dart`: Validates full app bootstrap, Riverpod scope, and initial smoke render.

### 3.2 Running Backend Webhook Reconciliation Tests

```powershell
node backend/server/test_webhook.js
```

**Expected Outcome**: Validates HMAC-SHA256 signature verification, replay prevention, and idempotency ledger logic.

### 3.3 Running Static Code Analysis

```powershell
$env:Path = "C:\flutter\bin;" + $env:Path
flutter analyze
```

**Expected Outcome**: `No issues found!` (0 errors, 0 warnings, 0 lints).

---

## 4. Architecture & Source Code References

For further details on system design, specifications, and deployment:

- [Setup.md](docs/Setup.md) — Workstation onboarding, Flutter toolchain, and pre-commit workflow.
- [Image Attributions.md](docs/Image%20Attributions.md) — Media asset licensing and Unsplash source catalog.
- [Business Requirement Specification.md](docs/Business%20Requirement%20Specification.md) — Detailed functional requirements and business rules.
- [Software Architecture.md](docs/Software%20Architecture.md) — Clean Architecture tiering, data flow diagrams, and state management specifications.
- [Deployment.md](docs/Deployment.md) — Multi-platform distribution guide (Web PWA, Google Play, Apple App Store).
- [backend/database/schema.sql](backend/database/schema.sql) — PostgreSQL 16 + PostGIS schema DDL & `get_nearby_restaurants` stored procedure.
- [backend/database/seed.sql](backend/database/seed.sql) — Real GPS coordinates and artisanal dish seed datasets.
- [backend/docker-compose.yml](backend/docker-compose.yml) — Container configuration for PostGIS and Redis services.
- [backend/server/webhook_reconciliation.js](backend/server/webhook_reconciliation.js) — Stripe webhook reconciliation and idempotency handler.
- [.github/workflows/ci.yml](.github/workflows/ci.yml) — GitHub Actions multi-platform CI/CD automation pipeline.
- [fastlane/Fastfile](fastlane/Fastfile) — Fastlane lanes for TestFlight and Google Play distribution.
- [lib/core/services/payment_service.dart](lib/core/services/payment_service.dart) — Stripe payment processing and amount calculations.
- [lib/core/services/secure_storage_service.dart](lib/core/services/secure_storage_service.dart) — Platform Keychain and KeyStore token persistence.
- [lib/core/services/location_service.dart](lib/core/services/location_service.dart) — Haversine geodesic distance, BR-04 ETA, and proximity sorting service.
- [lib/core/services/telemetry_service.dart](lib/core/services/telemetry_service.dart) — WebSocket telemetry gateway and order lifecycle state machine.
- [lib/features/tracking/presentation/courier_tracking_screen.dart](lib/features/tracking/presentation/courier_tracking_screen.dart) — Live courier tracking screen.
- [lib/features/discovery/data/restaurant_repository.dart](lib/features/discovery/data/restaurant_repository.dart) — `CachedRestaurantRepository` for offline resilience.
- [lib/features/cart/presentation/cart_controller.dart](lib/features/cart/presentation/cart_controller.dart) — Riverpod `CartController` source code.
- [lib/features/cart/presentation/widgets/merchant_conflict_dialog.dart](lib/features/cart/presentation/widgets/merchant_conflict_dialog.dart) — Single-merchant conflict modal implementation.
- [lib/features/discovery/presentation/home_screen.dart](lib/features/discovery/presentation/home_screen.dart) — Main discovery and search screen.
- [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart) — Declarative GoRouter routing table.
