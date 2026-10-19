# Multi-Platform Deployment & Distribution Guide
## Project: Stream Works (`pos`)

---

### Document Overview

This document provides complete, production-grade instructions for building and deploying **Stream Works** across three distinct channels:
1. **Progressive Web App (PWA)**: Immediate web hosting with **"Add to Home Screen"** capability for iPhones and Android devices (no App Store approval required).
2. **Native Android**: Release packaging for **Google Play Store** (`.aab`) and direct sideloading (`.apk`).
3. **Native iOS**: Packaging for **Apple TestFlight** and the **Apple App Store** (`.ipa`), including building from a Mac and building from Windows via Cloud CI/CD.

---

## Multi-Platform Distribution Matrix

| Platform Channel | Deliverable Artifact | Store Review Needed? | Developer Cost | Distribution Speed | Best Suited For |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **Web PWA ("Add to Home Screen")** | Static HTML5 / JS / CanvasKit / Wasm (`build/web/`) | ❌ **No** | **Free** (Cloudflare / GitHub Pages) | **Instant** ($< 2\text{ minutes}$) | Rapid client demos, internal testing, MVP launch, direct link sharing without App Store friction. |
| **Android (Direct APK)** | `app-release.apk` | ❌ **No** | **Free** | Instant | Direct device sideloading, enterprise field trials. |
| **Android (Google Play)** | `app-release.aab` (Android App Bundle) | ✅ **Yes** | $25 one-time fee | 1–3 business days | Universal consumer distribution across Android ecosystem. |
| **iOS (TestFlight Beta)** | `.ipa` archive | ✅ Quick (Automated) | $99/year (Apple Dev) | 1–2 hours | Closed/Open beta testing on iPhones up to 10,000 testers. |
| **iOS (Apple App Store)** | `.ipa` archive | ✅ Full Review | $99/year (Apple Dev) | 24–48 hours | Official public release in Apple App Store. |

---

## 1. Web App & iPhone "Add to Home Screen" Deployment (PWA)

A Progressive Web App (PWA) gives users on iPhones and Android devices a full-screen, app-like experience without having to download anything from an App Store.

### 1.1 How "Add to Home Screen" Works on iPhone

When deployed to an HTTPS web URL:
1. The user opens the web link in **Safari** on their iPhone (e.g., `https://streamworks.app`).
2. The user taps the **Share** button (the square with an arrow pointing upward at the bottom of Safari).
3. The user scrolls down the action sheet and taps **"Add to Home Screen"**.
4. The user confirms by tapping **"Add"** in the top right corner.
5. **The Result**:
   * A dedicated **Stream Works** app icon is created on the iPhone home screen.
   * Launching from the home screen runs the application in **standalone full-screen mode** with no Safari URL bar, navigation buttons, or browser chrome.
   * State, offline assets, and cached data are preserved locally.

```
       Safari View                          iOS Share Sheet                      Installed App
┌─────────────────────────┐            ┌─────────────────────────┐            ┌─────────────────────────┐
│ https://streamworks.app │            │ Share / Actions         │            │ [App Icon on Home Screen]│
├─────────────────────────┤            ├─────────────────────────┤            └────────────┬────────────┘
│                         │            │ [ Copy Link           ] │                         │ Tapped
│       Stream Works      │            │ [ Add Bookmark        ] │                         ▼
│    Nearby Restaurants   │  ────►     │ [ Add to Favorites    ] │  ────►     ┌─────────────────────────┐
│                         │            │ [ Add to Home Screen  ] │            │       Stream Works      │
│                         │            └─────────────────────────┘            │  (Full Screen - No URL) │
└─────────────────────────┘                                                   │   Native-like UI        │
                                                                              └─────────────────────────┘
```

### 1.2 PWA Configuration in Codebase

The Stream Works repository is pre-configured for iOS PWA standalone execution:

#### Web Manifest ([web/manifest.json](web/manifest.json))
```json
{
    "name": "Stream Works",
    "short_name": "StreamWorks",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#FAFAFA",
    "theme_color": "#FF6E40",
    "description": "On-demand food ordering and delivery",
    "orientation": "portrait-primary",
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
```

#### Apple iOS Web Meta Tags ([web/index.html](web/index.html#L23-L28))
```html
<!-- iOS Meta Tags for Standalone Execution -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Stream Works">
<link rel="apple-touch-icon" href="icons/Icon-192.png">
```

### 1.3 Building the Release Web Bundle

Run the Flutter release compilation:
```powershell
# Set Flutter path in PowerShell if not in PATH
$env:Path = "C:\flutter\bin;" + $env:Path

# Build production bundle
flutter build web --release
```
*Output directory*: `build/web/`

### 1.4 Hosting Providers & Step-by-Step Deployment

#### Option A: Cloudflare Pages (Recommended — Free, Fastest Edge CDN)
1. Install Cloudflare Wrangler CLI (optional) or use the Cloudflare Dashboard:
   ```powershell
   npx wrangler pages deploy build/web --project-name=stream-works
   ```
2. Or in the Cloudflare Dashboard:
   - Connect your GitHub repository.
   - Build Command: `flutter/bin/flutter build web --release`
   - Output Directory: `build/web`
3. Instantly provides a globally distributed HTTPS URL (e.g., `https://meal-express.pages.dev`).

#### Option B: GitHub Pages (Free)
1. Install `peanut` to automatically push builds to your `gh-pages` branch:
   ```powershell
   dart pub global activate peanut
   peanut --extra-args="--base-href=/posme/"
   git push origin gh-pages
   ```
2. In GitHub repository settings $\rightarrow$ Pages $\rightarrow$ Set source to `gh-pages` branch.

#### Option C: Firebase Hosting (Free Tier)
1. Initialize Firebase:
   ```powershell
   npm install -g firebase-tools
   firebase login
   firebase init hosting
   ```
   *Set public directory to: `build/web`*
2. Deploy:
   ```powershell
   firebase deploy --only hosting
   ```

---

## 2. Native Android Deployment (Google Play & Direct APK)

### 2.1 Generating Android Platform Files (If Missing)
If the `android/` directory is not yet generated in the workspace:
```powershell
flutter create --platforms=android .
```

### 2.2 Generating an Upload Keystore (App Signing)
Google Play requires all release builds to be signed with a cryptographic key:

1. Open PowerShell and run the Java `keytool` utility:
   ```powershell
   keytool -genkey -v -keystore "C:\Users\boriswu\upload-keystore.jks" `
       -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
       -alias upload
   ```
2. Create `android/key.properties` (never commit this file to public git):
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=C:\\Users\\boriswu\\upload-keystore.jks
   ```
3. Reference `key.properties` in `android/app/build.gradle`:
   ```groovy
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           release {
               keyAlias = keystoreProperties['keyAlias']
               keyPassword = keystoreProperties['keyPassword']
               storeFile = file(keystoreProperties['storeFile'])
               storePassword = keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.release
           }
       }
   }
   ```

### 2.3 Compiling Android Release Packages

* **For Google Play Store Release (AAB)**:
  ```powershell
  flutter build appbundle --release
  ```
  *Output Artifact*: `build/app/outputs/bundle/release/app-release.aab`

* **For Direct Testing / Sideloading (APK)**:
  ```powershell
  flutter build apk --release --split-per-abi
  ```
  *Output Artifacts*:
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (Older phones)
  - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (Modern phones)

### 2.4 Google Play Console Publishing Steps
1. Log in to [Google Play Console](https://play.google.com/console).
2. Create new Application $\rightarrow$ Enter title "Stream Works", default language, and app type.
3. Under **Testing** $\rightarrow$ **Internal testing**, create a new release.
4. Upload `app-release.aab`.
5. Add internal testers via email list. Testers receive an immediate link to install from Google Play.

---

## 3. Native iOS Deployment (TestFlight & Apple App Store)

### 3.1 Generating iOS Platform Files (If Missing)
```powershell
flutter create --platforms=ios .
```

### 3.2 Prerequisites for iOS Distribution
* **Apple Developer Program Enrollment**: Requires active membership ($99 USD/year) at [developer.apple.com](https://developer.apple.com).
* **Bundle Identifier**: Defined in `ios/Runner.xcodeproj` (e.g., `com.company.streamworks`).
* **Hardware Requirement**: Building native iOS binaries requires macOS with Xcode. If developing on Windows, use **Cloud CI/CD** (detailed below in Section 3.4).

### 3.3 Building on macOS

1. Navigate to project root:
   ```bash
   cd posme
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```
2. Build the production archive:
   ```bash
   flutter build ipa --release
   ```
3. Upload to App Store Connect via Xcode or Transporter:
   ```bash
   xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa \
       --apiKey <API_KEY> --apiIssuer <ISSUER_ID>
   ```

### 3.4 Building iOS from Windows via Cloud CI/CD (GitHub Actions)

You **do not need a Mac on your desk** to deploy to TestFlight or the App Store. You can configure GitHub Actions to build on a virtual macOS runner:

Create `.github/workflows/deploy_ios.yml`:
```yaml
name: Deploy iOS to TestFlight

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build_ios:
    runs-on: macos-14
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Tests
        run: flutter test

      - name: Setup Apple Certificates & Profiles
        uses: apple-actions/import-codesign-certs@v3
        with:
          p12-file-base64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
          p12-password: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}

      - name: Build IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}
```

---

## 4. Multi-Platform Automated CI/CD Workflow

Here is the master GitHub Actions pipeline automating Web PWA deployment, Android Google Play deployment, and iOS TestFlight packaging in a single unified workflow:

```
                            [ Push to Main or Release Tag ]
                                          │
                                          ▼
                       ┌─────────────────────────────────────┐
                       │   Static Analysis & Test Runner     │
                       │   flutter test  &&  flutter analyze │
                       └──────────────────┬──────────────────┘
                                          │ (If tests pass)
                  ┌───────────────────────┼───────────────────────┐
                  ▼                       ▼                       ▼
        [ Web PWA Build ]       [ Android AAB Build ]     [ macOS iOS IPA Build ]
                  │                       │                       │
                  ▼                       ▼                       ▼
        Deploy to Cloudflare      Deploy to Google        Deploy to TestFlight
        Pages / GitHub Pages      Play Console Track      & App Store Connect
```

Create `.github/workflows/ci_cd.yml`:
```yaml
name: Stream Works Multi-Platform Pipeline

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

jobs:
  verify:
    name: Lint & Test Verification
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  deploy_web_pwa:
    name: Deploy Web PWA to Cloudflare Pages
    needs: verify
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: 'meal-express'
          directory: 'build/web'
```

---

## 5. Post-Deployment Checklist & Verification

Before announcing releases to end customers:
- [ ] **HTTPS Enforced**: Ensure SSL/TLS is active on web domain (iOS Safari blocks PWA service workers on unencrypted HTTP).
- [ ] **Asset Rendering Check**: Verify all food and restaurant images render crisp without broken links.
- [ ] **Cart Mutation Verification**: Verify quantity incrementing and total price updating operates reliably on mobile viewports.
- [ ] **Add to Home Screen Test**: Open web URL in Safari on an iPhone; confirm prompt appears, install to Home Screen, and verify that launching executes in standalone full-screen mode.
- [ ] **Orientation Lock**: Confirm the interface stays upright in `portrait-primary` mode on mobile devices.
