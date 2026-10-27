# Pairly — Premium Couple Live Location App

Pairly is an intimate, private, mutual live location-sharing application crafted specifically for couples. Built with Flutter, GetX, Google Maps, and Firebase (Auth + Cloud Firestore).

Pairly prioritizes privacy, consent, and refined design:
- **Never Silently Tracks:** Location streaming is never activated without manual consent.
- **Privacy Center:** Instant pause, disconnect, block, or account deletion at any time.
- **Freshness First:** Strictly distinguishes between **Live**, **Paused**, **Stale**, **Permission Denied**, **GPS Off**, and **Disconnected** states.
- **Single Latest Document:** Location coordinates are not stockpiled into infinite historical breadcrumbs. Only the latest valid coordinate is held in Firestore (`locations/{uid}`).
- **Zero Crash Resiliency:** Full offline/local demo testing mode is automatically supported when Firebase credentials have not yet been placed, allowing instant testing of UI, navigation, pairing, and radar preview out of the box!

---

## 🎨 Visual Identity

- **Primary Background:** `#090B10`
- **Secondary Background:** `#10151D`
- **Elevated Cards:** `#151D27`
- **Primary Accent:** `#C5F467` (Lime)
- **Secondary Accent:** `#8DD8C4` (Mint)
- **Typography:** Google Fonts Inter

---

## 🚀 Key Features

1. **Onboarding & Auth Flow**
   - Brand Splash with smooth state evaluation.
   - Welcome intro highlighting mutual consent and private 1:1 encryption.
   - Register, Sign In, Forgot Password, and Profile Setup.

2. **Secure 1:1 Partner Pairing**
   - Single-use, expiring 6-character uppercase pairing codes.
   - Integration with native Android OS Share Sheet.
   - Rejection of self-pairing and duplicate connections.
   - Mutual confirmation.

3. **Live Couple Map**
   - Full-screen Google Map with dark styling.
   - Custom-rendered circular canvas markers with partner initials.
   - Dynamic accuracy circles, fit both markers, and recenter actions.
   - Real-time distance and estimated travel time calculations.

4. **Location Sharing Flow**
   - Android foreground stream throttled with 15m distance filter.
   - Clear indicators of accuracy and last upload timestamp.
   - Granular Start/Stop stream controls.

5. **Privacy & Trust Center**
   - Access transparency report ("Who can see my location").
   - Instant permission settings shortcut.
   - One-tap Disconnect and Block protocols.
   - Permanent account and data purge.

6. **Safe Arrival Alerts**
   - Customizable destination with adjustable perimeter radius (50m–500m).
   - Proximity detection and automatic arrival notification.

---

## 🛠️ Verification & Quality Bar

- **Static Analysis:** `flutter analyze` completed with **0 issues**.
- **Automated Tests:** 14 unit and widget tests covering models, distance formulas, expiration logic, and form validators passed with **100% success**.
- **Setup Guide:** Complete step-by-step instructions available in `SETUP_GUIDE.md`.
