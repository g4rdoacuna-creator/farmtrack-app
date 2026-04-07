# FarmTrack — Native Flutter Livestock & Farm Management App

> A real, production-grade Flutter app with SQLite, local push notifications, and premium UI.
> Installable directly as an APK — no Play Store required.

---

## What This Is

**Not a website. Not a webview. A real native Android/iOS app.**

- Built with **Flutter 3.x** (Dart) — same tech as Google Pay, BMW, eBay
- **SQLite** via `sqflite` — real embedded database, not localStorage
- **Local notifications** for task reminders (works offline)
- **Material You** design with custom Plus Jakarta Sans typography
- **Offline-first** — zero internet required after install
- Sideloadable APK — no Google Play / App Store needed

---

## Screenshots (Design)

```
┌────────────────────────┐  ┌────────────────────────┐
│ 🌾 My Farm  |  🔔 ⚙️  │  │  ← Animals             │
│                        │  │                        │
│ ╔══════════════════════╗  │  🐷 Pig                │
│ ║  Total Profit        ║  │  ├ 2 active · 2 total  │
│ ║  +₱18,650            ║  │  ├ Income: ₱10,800     │
│ ║  Income  Expense     ║  │  ├ Expense: ₱9,200     │
│ ╚══════════════════════╝  │  └ Profit: +₱1,600     │
│                        │  │                        │
│ Animal Overview        │  │  🐔 Chicken            │
│ ┌─ 🐷 Pig ──────────┐  │  │  ├ 1 active · 2 total │
│ └──────────────────┘  │  └────────────────────────┘
└────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.22+ (Dart) |
| Database | SQLite via `sqflite` ^2.3.3 |
| State | `provider` ^6.1.2 |
| Charts | `fl_chart` ^0.68.0 |
| Typography | `google_fonts` (Plus Jakarta Sans) |
| Notifications | `flutter_local_notifications` ^17.2.2 |
| Animations | `flutter_animate` ^4.5.0 |
| Export | `share_plus` + `path_provider` |
| Security | `flutter_secure_storage` |
| IDs | `uuid` |

---

## Prerequisites

```bash
# 1. Install Flutter SDK
# https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# You need:
# ✓ Flutter (Channel stable, 3.22.x)
# ✓ Android toolchain (Android SDK, command-line tools)
# ✓ Android Studio OR VS Code with Flutter extension
```

---

## Build & Install

### Option A — USB Install (Fastest)

```bash
# Connect your Android phone via USB
# Enable Developer Options → USB Debugging

cd farmtrack

# Get dependencies
flutter pub get

# Run directly on device (debug)
flutter run

# OR build release APK
flutter build apk --release

# APK location:
# build/outputs/flutter-apk/app-release.apk

# Install via ADB
adb install build/outputs/flutter-apk/app-release.apk
```

### Option B — Build APK, Transfer to Phone

```bash
flutter build apk --release

# Transfer the APK to your phone via:
# - USB cable (copy to Downloads)
# - Google Drive / Dropbox / email
# - Local WiFi with: python3 -m http.server 8080
#   then open http://YOUR_PC_IP:8080 on phone

# On phone: tap APK → Allow install from unknown sources
```

### Option C — Build Split APKs (Smaller File Size)

```bash
flutter build apk --split-per-abi

# Creates 3 APKs optimized for each architecture:
# - app-armeabi-v7a-release.apk  (~15 MB) — older phones
# - app-arm64-v8a-release.apk    (~18 MB) — most modern phones
# - app-x86_64-release.apk       (~20 MB) — emulators

# Install the arm64 one for any phone made after 2017
```

### Option D — iOS (Sideload via AltStore, no App Store)

```bash
# On Mac with Xcode installed:
flutter build ios --release --no-codesign

# Then use AltStore (altstore.io) to sideload .ipa
# OR use Xcode to push directly to your device with free Apple ID
```

---

## Project Structure

```
farmtrack/
├── lib/
│   ├── main.dart                  # Entry point, routes, bottom nav
│   ├── core/
│   │   ├── theme.dart             # Design system (colors, fonts, radii)
│   │   └── database.dart          # SQLite layer, seeding, all CRUD
│   ├── providers/
│   │   └── farm_provider.dart     # Central state (ChangeNotifier)
│   ├── screens/
│   │   ├── pin_screen.dart        # PIN lock screen
│   │   ├── dashboard_screen.dart  # Home with stats + charts
│   │   ├── animals_screen.dart    # Animal categories + batch detail
│   │   └── other_screens.dart     # Finance, Tasks, Reports, Settings
│   └── widgets/
│       └── shared_widgets.dart    # Reusable cards, tiles, etc.
├── android/
│   └── app/
│       ├── build.gradle           # Android SDK config
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── res/values/styles.xml
└── pubspec.yaml                   # All dependencies
```

---

## App Architecture

```
                    ┌──────────────────────┐
                    │     main.dart         │
                    │  MaterialApp + Router │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
         PinScreen         HomeShell         Routes
                               │
        ┌──────────────────────┼──────────────────────────┐
        │              │              │              │      │
   Dashboard       Animals        Finance         Tasks  Reports
        │              │              │              │
        └──────────────┴──────────────┴──────────────┘
                               │
                        FarmProvider
                     (ChangeNotifier)
                               │
                        DatabaseHelper
                         (SQLite — sqflite)
                               │
                    ┌──────────┴──────────┐
                    │                      │
               animals.db          (tables)
              batches table         tasks
           transactions table     settings
```

---

## Default Login

**PIN: `1234`**

Change in: Settings → Change PIN

---

## Features by Screen

### 🏠 Dashboard
- Hero profit card (green gradient)
- Income/Expense/Profit summary
- Animal overview cards with per-type P&L
- Upcoming tasks (next 4 due)
- 6-month income vs expense bar chart
- Pull-to-refresh

### 🐾 Animals
- Color-coded animal cards (Pig=orange, Chicken=yellow, Goat=blue, Cow=purple)
- Add custom animal types with emoji
- Drill into batches per animal
- Per-batch P&L in real-time from SQLite

### 💰 Finance
- Filter by: All / Expense / Income / Feed / Medicine / Labor / Sales / Transport
- Swipe-to-delete transactions
- Attach transactions to specific batches
- Real-time summary bar

### ✅ Tasks
- 3 tabs: Due Today / Upcoming / All
- Tap to mark done (auto-schedules next occurrence)
- Swipe to delete
- Supports daily / weekly / monthly frequency
- Visual urgency indicators (overdue = red, today = amber)

### 📈 Reports
- Farm totals summary
- Expense breakdown pie chart (fl_chart)
- Per-animal profit ranking
- Per-batch P&L table
- CSV export via native share sheet

### ⚙️ Settings
- Farm name, currency symbol
- PIN change
- CSV export
- Full data reset

---

## Customization for Production

### Add Push Notifications (Background)
```dart
// Already wired in AndroidManifest.xml
// In farm_provider.dart, add after markTaskDone():
await NotificationService.scheduleReminder(
  task.title, 
  nextDue.subtract(Duration(hours: 6)),
);
```

### Add Cloud Sync (Optional)
```yaml
# Add to pubspec.yaml:
firebase_core: ^3.0.0
cloud_firestore: ^5.0.0
```

### Switch to Riverpod (Scale Up)
```yaml
flutter_riverpod: ^2.5.1
```

### Add Fingerprint/Face ID
```yaml
local_auth: ^2.3.0
```

---

## Common Build Issues

**`flutter doctor` shows Android SDK issues:**
```bash
flutter doctor --android-licenses
# Accept all licenses
```

**Build fails with Java error:**
```bash
# Set Java 17
export JAVA_HOME=/path/to/java17
```

**APK too large?**
```bash
flutter build apk --split-per-abi --release
# Use arm64 APK — it's the smallest for modern phones
```

**"App not installed" on phone:**
- Enable: Settings → Security → Install unknown apps
- If replacing an existing install, uninstall first

---

## Data Model (SQLite Schema)

```sql
animals:      id, name, emoji, color, sort_order, created_at
batches:      id, animal_id, name, quantity, start_date, status, notes, created_at
transactions: id, batch_id, animal_id, type, amount, date, category, notes, created_at
tasks:        id, title, animal_id, batch_id, frequency, next_due, last_done, notes, created_at
settings:     key, value
```

---

*FarmTrack — Built with Flutter · SQLite · No internet required · Made for Filipino farmers 🌾*
