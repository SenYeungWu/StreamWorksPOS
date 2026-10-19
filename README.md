# Stream Works (POS) 🍔🛵

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-00C4B4)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Router-GoRouter-blue)](https://pub.dev/packages/go_router)
[![Database](https://img.shields.io/badge/Database-PostgreSQL-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Stream Works** is an enterprise-grade, cross-platform on-demand food ordering and mobile Point of Sale (POS) platform. It connects hungry consumers, local restaurant merchants, and courier fulfillment networks into a seamless, unified digital ecosystem.

Built on a **Feature-First Clean Architecture**, the project combines a reactive Flutter frontend (supporting iOS, Android, and Web) with declarative navigation, robust state management, and backend services for transactional webhook reconciliation and spatial database management.

---

## 🚀 Key Features

* **🍽️ Location-Aware Discovery & Search**: Filter merchants by distance, cuisine rating, delivery speed, and pricing tier, complete with dietary tags and dish searching.
* **🛒 Smart Cart & Checkout**: Real-time subtotal, fee, tip, and tax calculation, one-tap reordering from past history, and multi-merchant basket conflict resolution dialogs.
* **📍 Live Courier Tracking & Geolocation**: Seamless GPS telemetry tracking delivery progression across order states (*Placed*, *Confirmed*, *Preparing*, *Out for Delivery*, *Delivered*).
* **💳 Payment & Reconciliation**: Stripe checkout integration accompanied by an idempotent Node.js webhook reconciliation engine to ensure zero lost transactions.

---

## 🛠️ Tech Stack & Architecture

### Client (Frontend)
* **Framework**: [Flutter](https://flutter.dev) (iOS, Android, Web)
* **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
* **Routing & Navigation**: [GoRouter](https://pub.dev/packages/go_router)
* **Device Services**: [Geolocator](https://pub.dev/packages/geolocator) (GPS & location-awareness)
* **Design & Icons**: Material 3 & Cupertino Icons

### Backend & Infrastructure
* **Services**: Node.js webhook reconciliation service (`backend/server/`)
* **Database**: PostgreSQL with PostGIS spatial indexing (`backend/database/`)
* **Containerization**: Docker Compose (`backend/docker-compose.yml`)
* **CI/CD & Mobile Release**: Fastlane & GitHub Actions

---

## 📂 Repository Structure

```text
StreamWorksPOS/
├── assets/              # Static media, icons, and restaurant images
├── backend/
│   ├── database/        # PostgreSQL schema definitions and seed data
│   ├── server/          # Node.js webhook reconciliation and test harnesses
│   └── docker-compose.yml
├── docs/                # Comprehensive architectural and business documentation
├── lib/
│   ├── core/            # Global themes, constants, utilities, and network configs
│   ├── data/            # Mock/remote data repositories and data sources
│   ├── features/        # Feature modules organized by domain (Clean Architecture)
│   ├── models/          # Strongly-typed domain data models
│   ├── screens/         # UI pages (Home, Restaurant, Cart, Tracking, Profile)
│   ├── widgets/         # Reusable presentation widgets and components
│   └── main.dart        # Application entrypoint and provider scope initialization
└── test/                # Unit, widget, and state management tests
```

---

## 🏁 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0 < 4.0.0`)
* [Dart SDK](https://dart.dev/get-dart)
* [Docker & Docker Compose](https://www.docker.com/) (for local database services)
* [Node.js](https://nodejs.org/) (`>= 18.x`, for backend webhook runner)

### 1. Clone & Install Dependencies
```bash
# Get Flutter dependencies
flutter pub get

# (Optional) Install backend webhook dependencies
cd backend/server && npm install && cd ../..
```

### 2. Start Local Backend & Database
```bash
cd backend
docker-compose up -d
cd ..
```

### 3. Run the Flutter App
```bash
# Check connected devices
flutter devices

# Launch on Chrome (Web)
flutter run -d chrome

# Launch on connected mobile emulator or physical device
flutter run
```

### 4. Running Tests & Analyzer
```bash
# Run static code analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

---

## 📚 Documentation

For in-depth technical details, consult the specifications in the [`docs/`](./docs) directory:

* 📄 [Business Requirement Specification (BRS)](./docs/Business%20Requirement%20Specification.md) — Comprehensive functional, non-functional, and user stories.
* 🏗️ [Software Architecture Document (SAD)](./docs/Software%20Architecture.md) — High-level system design, Clean Architecture layers, state diagrams, and patterns.
* 🛠️ [Setup Guide](./docs/Setup.md) — Step-by-step developer workstation onboarding and toolchain setup.
* 🚢 [Deployment Guide](./docs/Deployment.md) — Production build steps, environment variables, and store release instructions.
* 📖 [User Guide](./docs/User%20Guide.md) — End-user instructions and workflow walkthroughs.
* 🖼️ [Asset & Image Attributions](./docs/Image%20Attributions.md) — Licensing and photography catalog (Unsplash).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
