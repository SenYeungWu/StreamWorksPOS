# Environment Setup & Development Guide
## Project: Stream Works (`pos`)

---

### Document Overview

This guide details the complete workstation configuration, runtime prerequisites, development workflow, and testing environment required to build, run, and verify the **Stream Works (`pos`)** multi-platform application.

---

## 1. System Prerequisites & Hardware Specifications

| Component | Minimum Specification | Recommended Specification |
| :--- | :--- | :--- |
| **Operating System** | Windows 10/11 (64-bit), macOS 13+, or Ubuntu 22.04 LTS | Windows 11 (64-bit) or macOS Sonoma (Apple Silicon) |
| **Processor** | 4-Core x86_64 / ARM64 CPU | 8-Core Intel Core i7/i9, AMD Ryzen 7, or Apple M2/M3 |
| **Memory (RAM)** | 8 GB RAM | 16 GB - 32 GB RAM (for concurrent emulator execution) |
| **Storage** | 15 GB free disk space | 50 GB+ NVMe SSD |
| **Shell Environment** | Windows PowerShell 5.1 / PowerShell 7+ | PowerShell 7+ with Windows Terminal |

---

## 2. Flutter & Dart Toolchain Setup

### 2.1 Installing the Flutter SDK (Stable Channel)

1. **Clone the Official Flutter Repository**:
   Open an elevated terminal and clone the stable branch into a standard directory (e.g., `C:\flutter`):
   ```powershell
   git clone -b stable --depth 1 https://github.com/flutter/flutter.git C:\flutter
   ```

2. **Configure System `PATH`**:
   Add the Flutter binary directory to your User Environment Variables:
   ```powershell
   # Add to current PowerShell session
   $env:Path = "C:\flutter\bin;" + $env:Path

   # Persist permanently for user environment
   [System.Environment]::SetEnvironmentVariable(
       "Path",
       "C:\flutter\bin;" + [System.Environment]::GetEnvironmentVariable("Path", "User"),
       "User"
   )
   ```

3. **Verify Installation & Engine Artifacts**:
   Execute the doctor diagnostic tool to check toolchain dependencies:
   ```powershell
   flutter doctor -v
   ```

### 2.2 Platform Toolchain Configurations

#### A. Web Development & Testing (Fastest Iteration)
* **Google Chrome** or **Microsoft Edge** installed.
* Flutter Web compiles out-of-the-box with CanvasKit and HTML renderers.

#### B. Android Mobile Development
* **Android Studio**: Install latest version with **Android SDK Command-line Tools** and **Android SDK Platform-Tools**.
* Accept Android licenses:
  ```powershell
  flutter doctor --android-licenses
  ```
* Configure an Android Virtual Device (AVD) running Android 13 or 14 (API 33/34).

#### C. Windows Desktop Development
* **Visual Studio 2022**: Install with the **"Desktop development with C++"** workload enabled (including MSVC v143, CMake, and Windows 10/11 SDK).

---

## 3. Project Workspace Setup & Initialization

### 3.1 Repository Initialization
1. Clone the repository and navigate into the project directory:
   ```powershell
   git clone https://github.com/SenYeungWu/StreamWorksPOS.git
   cd StreamWorksPOS
   ```

2. **Fetch Dependencies**:
   Install all project packages declared in `pubspec.yaml`:
   ```powershell
   flutter pub get
   ```

3. **Asset Verification**:
   Verify that local image assets are available in `assets/images/`:
   ```powershell
   Get-ChildItem -Path "assets/images"
   ```

---

## 4. Running the Application Locally

### 4.1 Device Discovery
Query available connected target devices, emulators, and browsers:
```powershell
flutter devices
```

### 4.2 Launching Development Server
* **Launch in Google Chrome (Web)**:
  ```powershell
  flutter run -d chrome
  ```
* **Launch in Microsoft Edge (Web)**:
  ```powershell
  flutter run -d edge
  ```
* **Launch on Android Emulator / Physical Device**:
  ```powershell
  flutter run -d android
  ```
* **Launch as Native Windows Desktop App**:
  ```powershell
  flutter run -d windows
  ```

### 4.3 Developer Ergonomics & Hot Reload
While `flutter run` is active in the terminal:
* Press `r` — **Hot Reload**: Instantly updates UI changes while preserving app state ($< 1\text{ second}$).
* Press `R` — **Hot Restart**: Resets application state and rebuilds widget tree.
* Press `v` — Open **Flutter DevTools** in your default web browser for widget tree inspection, memory profiling, and network tracking.
* Press `q` — Quit and terminate running debug session.

---

## 5. Automated Testing Environment & Quality Gates

In accordance with test-driven development (TDD) best practices, **every feature must have an automated test created first**, and tests must be executed and passing prior to any git commit.

### 5.1 Test Suite Structure
```
test/
├── unit/                         # Domain models, pricing, Riverpod controllers, and services
│   ├── cached_repository_test.dart
│   ├── cart_controller_test.dart
│   ├── cart_test.dart
│   ├── location_service_test.dart
│   ├── models_test.dart
│   ├── payment_service_test.dart
│   ├── restaurant_repository_test.dart
│   ├── secure_storage_test.dart
│   └── telemetry_service_test.dart
├── widget/                       # UI component and screen integration tests
│   ├── cart_screen_test.dart
│   ├── clean_ui_test.dart
│   └── restaurant_screen_test.dart
└── widget_test.dart              # Core smoke test
```

### 5.2 Executing Automated Tests

* **Run Entire Test Suite**:
  ```powershell
  flutter test
  ```

* **Run Specific Test File**:
  ```powershell
  flutter test test/widget_test.dart
  ```

* **Run Tests with Code Coverage**:
  ```powershell
  flutter test --coverage
  ```
  *Coverage output is generated at `coverage/lcov.info`.*

### 5.3 Static Analysis & Code Formatting

* **Execute Static Code Analysis**:
  ```powershell
  flutter analyze
  ```
  *Ensures compliance with rules defined in [analysis_options.yaml](analysis_options.yaml).*

* **Auto-Format Codebase**:
  ```powershell
  dart format lib test
  ```

---

## 6. Pre-Commit Verification Workflow

Follow this standard pre-commit sequence before issuing any `git commit`:

```powershell
# 1. Run all unit and widget tests
flutter test

# 2. Verify static analysis passes with zero warnings
flutter analyze

# 3. Format all code files
dart format --set-exit-if-changed lib test

# 4. Check git status
git status
```

---

## 7. Troubleshooting & Environment Recovery

| Symptom / Error | Root Cause | Solution / Remediation |
| :--- | :--- | :--- |
| `'flutter' is not recognized as internal or external command` | `C:\flutter\bin` missing from environment `$env:Path`. | Add `C:\flutter\bin` to PATH in current PowerShell session: `$env:Path = "C:\flutter\bin;" + $env:Path`. |
| `Version solving failed` during `flutter pub get` | Dependency cache or SDK constraint mismatch. | Run `flutter clean`, remove `pubspec.lock`, and rerun `flutter pub get`. |
| Gradle build failure on Android | Incompatible JDK or corrupt Gradle daemon cache. | Delete `.gradle/` folder in project root and user profile: `Remove-Item -Recurse -Force .gradle`. |
| Image assets not rendering on screen | Asset path unlisted or misaligned in `pubspec.yaml`. | Ensure `assets/images/` is registered under `flutter: assets:` in `pubspec.yaml`. |
| Port conflict on Web (`localhost:XXXXX`) | Previous debug session dangling. | Run `Get-Process -Name chrome, dart | Stop-Process` or specify custom port: `flutter run -d chrome --web-port 8080`. |
