# Dotz — Live Wallpaper

A beautiful Flutter & Native Android app that generates dynamic, live wallpapers visualizing your time. Track your year, your life, or your specific goals using highly customizable dot grids and glass aesthetics.

---

## 📱 Features

- **True Live Wallpaper Engine** — Runs natively on Android using Kotlin `WallpaperService` for zero battery drain and instant updates.
- **Multiple Time Perspectives**:
  - **Year Mode:** A 365-dot continuous grid showing your progress through the current year.
  - **Weekly/Monthly Mode:** A clean 12-month layout broken down by weeks and days (Standard Calendar view).
  - **Life Mode:** Enter your birthdate and life expectancy to see your entire life visualized in dots.
  - **Goal Mode:** Set a custom target date and watch the dots count down.
- **Rich Dot Shapes**: Choose between solid **Circles**, rounded **Squares**, **Stars**, or beautiful translucent **Glass Bubbles**.
- **Advanced Customization**:
  - 🖼️ Custom Background Images (from Gallery) with auto-scaling and center-cropping.
  - 🎨 Dot colors (Past / Today / Future).
  - 🌅 Background solid colors.
  - 📐 Dynamic grid density (automatically scales for dense Life modes).
- **Dynamic Labels & Quotes**:
  - Display progress percentages and days remaining.
  - Fetch daily inspirational quotes via API.
  - Write your own custom lockscreen text.
- **Lockscreen Simulation** — The Flutter app features a true-to-life Lockscreen preview (complete with status bar, gesture pill, and clock) so you know exactly how it looks before applying.
- **Native Glass UI** — The app interface is built with stunning blur, translucency, and frosted glass components.

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10+ SDK
- Dart 3.0+
- Android Studio (Required for compiling the native Kotlin Live Wallpaper service)

### Environment Setup

You will need to set up a `.env` file in the root directory for the Quote API to work:

1. Create a file named `.env` in the root of your project.
2. Add your API key/URL:

```env
API_KEY=your_quote_api_url_here
```

### Run the App

```bash
flutter pub get
flutter run
```

### Build Release APK (Android Only)

> **Note:** Dotz currently uses Android's native `WallpaperService`. iOS does not support third-party live wallpapers in the same way.

```bash
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point
├── core/
│   └── app_theme.dart         # Global colors and glass styles
├── models/
│   └── wallpaper_settings.dart# Settings model + day calculations + shapes
├── viewmodels/
│   └── home_view_model.dart   # State management & Native MethodChannels
├── views/
│   ├── home_screen.dart       # Main UI with simulated lockscreen preview
│   └── setting_page.dart      # Glass control panels for shapes/colors
└── widgets/
    ├── dot_grid_widget.dart   # Complex shape/grid rendering logic
    └── floating_nav_bar.dart  # Custom bottom navigation

android/app/src/main/kotlin/com/example/dotz/
├── MainActivity.kt            # Flutter engine & SharedPreferences bridge
└── DotzLiveWallpaper.kt       # High-performance Native Android Canvas rendering
```

---

## 🔧 How to Set as Wallpaper

1. Open the Dotz app and customize your grid, colors, shape, and background image.
2. Tap the **APPLY TO LOCK SCREEN** glass button.
3. The app will securely send your settings to the Android system and open the native wallpaper picker.
4. Tap **Set Wallpaper** and choose **Home Screen** or **Home and Lock Screen**.
5. Your dots will now update automatically in the background every day!

---

## 📄 Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_dotenv: ^5.1.0         # Secure API key management
  image_picker: ^1.0.4           # Background image selection
  path_provider: ^2.1.1          # Secure file saving for backgrounds
  shared_preferences: ^2.2.2     # Data persistence between Flutter and Android
  intl: ^0.18.1                  # Date and time formatting for the preview
```
