# dotz: live wallpaper

![dotz: your year, goal or life as dots on your lock screen](.github/assets/dotz-hero.jpg)

A native Android app (Kotlin + Jetpack Compose) that turns time into a grid of dots on your lock screen. Track your year, a month-by-month calendar, a goal countdown, or your whole life. Today's dot is **Pip**, the dotz mascot.

---

## Features

- **True live wallpaper:** a Kotlin `WallpaperService` redraws once a day, so it uses almost no battery and never needs the app reopened.
- **Four views**
  - **Year:** one dot per day of the current year.
  - **Month:** a 12-month calendar grid.
  - **Goal:** name a goal, pick a date, and count down.
  - **Life:** your life in weeks (or days) from your date of birth.
- **Make it yours:** past / today / future / background colours, six dot shapes (circle, square, diamond, hexagon, star, ring), grid density, date numbers inside dots, a background photo, and yearly marked dates (birthdays, anniversaries).
- **Today's dot:** a plain dot or Pip's face.
- **Labels:** progress ("50 days left · 86%"), a daily quote, or your own text.
- **Exact preview:** the in-app preview, the live wallpaper and the home-screen widget all use the same renderer (`DotGridRenderer.kt`), so what you see is what you get.
- **Home-screen widget** that mirrors the wallpaper.

---

## Getting started

### Prerequisites

- Android Studio (or JDK 17 + Android SDK 36)

### Quote API (optional)

The daily quote URL is read from a `.env` file in the repo root at build time. Without it, the free public [zenquotes.io](https://zenquotes.io) endpoint is used.

```bash
cp .env.example .env
```

### Build and run

```bash
cd android
./gradlew installDebug        # build + install on a connected device
./gradlew assembleRelease     # release APK (signed if android/key.properties exists)
./gradlew bundleRelease       # App Bundle for the Play Store
```

---

## Project structure

```
android/app/src/main/kotlin/com/wallpaper/dotz/
├── MainActivity.kt          # Compose entry point, navigation, apply flow
├── DotzViewModel.kt         # UI state + actions
├── DotGridRenderer.kt       # The one renderer: wallpaper, widget and preview
├── DotzLiveWallpaper.kt     # WallpaperService engine
├── DotzWidgetProvider.kt    # Home-screen widget
├── data/
│   ├── DotzState.kt         # Settings model, label + JSON helpers
│   └── DotzRepository.kt    # Draft/wallpaper prefs, quote fetch, background image
└── ui/
    ├── theme/Theme.kt       # Colours, Space Grotesk / Inter type
    ├── components/          # Pip, buttons, toggles, nav bar, sheets, date picker
    ├── screens/             # Splash, Onboarding, Home tabs, Look, Editor, Applied, ...
    └── WallpaperPreview.kt  # Phone preview + fake lock-screen clock
```

---

## Setting it as your wallpaper

1. Pick a view (Year, Month, Goal or Life) and style it in **Look**.
2. Tap **Set as wallpaper**.
3. The first time, Android's wallpaper picker opens: tap **Set wallpaper**. After that, changes apply instantly.
4. A new dot fills in every midnight.
