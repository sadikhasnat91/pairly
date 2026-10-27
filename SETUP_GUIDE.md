# Pairly — Setup & Configuration Guide

Pairly is a couples live-location sharing application built with **Flutter**, **GetX**, **Google Maps**, and **Firebase** (Authentication & Cloud Firestore).

---

## 1. Firebase Configuration

Pairly is fully built to connect directly to Firebase Cloud Firestore and Firebase Authentication. Additionally, it contains an automatic fallback testing engine so that the entire UI, pairing flow, live map radar, and safe arrival modules can be previewed even before Firebase keys are provisioned.

### Steps to connect your Firebase Project:

1. **Create a Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/).
   - Click **Add project** and name it (e.g., `pairly-prod`).

2. **Add Android App:**
   - Register an Android app with package name: `com.pairly.app.pairly`.
   - Download the generated `google-services.json` file.
   - Place `google-services.json` inside the `android/app/` folder.

3. **Enable Authentication Providers:**
   - In the Firebase Console, navigate to **Build > Authentication > Sign-in method**.
   - Enable **Email/Password**.

4. **Enable Cloud Firestore:**
   - Navigate to **Build > Firestore Database**.
   - Click **Create database** in Production mode.
   - Deploy the rules found in the root `firestore.rules` file:
     ```bash
     firebase deploy --only firestore:rules
     ```

---

## 2. Google Maps Android API Key

To render Google Maps on Android devices and emulators:

1. **Obtain API Key:**
   - Go to the [Google Cloud Console](https://console.cloud.google.com/).
   - Enable the **Maps SDK for Android**.
   - Generate an API Key under **Credentials**.
   - Restrict the key to Android applications with package name: `com.pairly.app.pairly` and your SHA-1 signing fingerprint.

2. **Configure in AndroidManifest.xml:**
   - Open `android/app/src/main/AndroidManifest.xml`.
   - Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual key:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_ACTUAL_GOOGLE_MAPS_KEY_HERE" />
     ```

---

## 3. Physical Device vs. Emulator Testing

| Feature | Physical Device | Android Emulator |
| :--- | :--- | :--- |
| **Real GPS Tracking** | Accurate hardware GPS sensor, respects actual motion & distance filtering | Uses simulated mock location points configured in Emulator Extended Controls (`...` > Location) |
| **Google Maps Rendering** | Works natively with valid API key | Requires Google Play system image (e.g. `Pixel 7 with Google Play`) |
| **Foreground Stream** | Stays active when app is open or minimized | Updates as long as emulator is running |
| **Share Sheet** | Invokes native Android OS share modal (`WhatsApp`, `SMS`, `Telegram`, etc.) | Opens emulator test share dialog |
| **Permission Dialogs** | Android system runtime permission popup (`While using app`, `Only this time`, `Don't allow`) | Standard Android emulator permission prompt |

---

## 4. Architecture & Directory Structure

```text
lib/
├── app/
│   ├── bindings/
│   │   └── initial_binding.dart      # GetX Dependency Injection (LazyPut with fenix)
│   └── routes/
│       ├── app_pages.dart            # GetPage route definitions & transitions
│       └── app_routes.dart           # Route name constants
├── core/
│   ├── constants/
│   │   ├── app_constants.dart        # Constants (stale threshold, default coords)
│   │   └── map_style.dart            # Dark mode JSON style for Google Maps
│   ├── theme/
│   │   ├── app_colors.dart           # #090B10, #C5F467, #8DD8C4 palette
│   │   ├── app_theme.dart            # Material3 dark ThemeData
│   │   └── app_typography.dart       # GoogleFonts Inter typography
│   ├── utils/
│   │   ├── date_formatter.dart       # Relative timeAgo, timestamps
│   │   ├── location_utils.dart       # Distance, bearing, bounds, freshness
│   │   └── validator.dart            # Form input validators
│   └── widgets/
│       ├── app_banner.dart           # Offline / GPS / permission banners
│       ├── app_button.dart           # Accessible button variants
│       ├── app_card.dart             # Dark elevated rounded cards
│       ├── app_dialog.dart           # Confirmation & action dialogs
│       ├── app_text_field.dart       # Text input fields
│       ├── connection_status_card.dart# Partner connection status card
│       ├── custom_bottom_nav.dart    # Floating rounded bottom nav
│       ├── location_sharing_card.dart# Main toggle card for live stream
│       ├── partner_avatar.dart       # Custom avatar with status ring
│       ├── skeleton_loader.dart      # Loading placeholders
│       └── status_badge.dart         # Live, Paused, Stale, Offline badges
├── data/
│   ├── models/                       # Typed JSON models (User, Partner, Location, etc.)
│   ├── repositories/                 # AuthRepository, PartnerRepository, LocationRepository
│   └── services/                     # FirebaseService, LocationService, StorageService
└── modules/
    ├── auth/                         # Sign in, Sign up, Forgot password
    ├── home/                         # Dashboard, Status, Compact Radar Preview
    ├── live_map/                     # Full-screen Google Map with markers & distance
    ├── main_layout/                  # Bottom nav navigation & view indexer
    ├── onboarding/                   # Welcome, Splash, Profile setup
    ├── partner/                      # Code generation, Enter code, Disconnect/Block
    ├── privacy/                      # Privacy & Trust Center, Permissions, Purge
    ├── profile/                      # Profile edit, change password, logout
    └── safe_arrival/                 # Destination perimeter alert system
```

---

## 5. Security & Privacy Guarantees

1. **No Silent Tracking:** Location streams are never initialized without explicit user toggle.
2. **Single Latest Location Document:** In Cloud Firestore (`locations/{uid}`), only the latest coordinate is stored with its accuracy and timestamp, avoiding unconsented trail logging.
3. **Immediate Revocation:** If a user pauses sharing or disconnects a partner, Firestore security rules and client-side listeners immediately cut off coordinate access.
4. **Stale Location Protection:** If an update is older than 15 minutes, the app visibly labels it as **Outdated Location** or **Offline**, preventing misleading timestamps.

