# 🔵 Dotz — Year in Dots

A beautiful Flutter app that generates a **365-dot grid wallpaper** showing your year progress — one dot per day.

---

## 📱 Features

- **365-dot grid** — one square per day of the year
- **Live year progress** — past days filled, today highlighted, future days dimmed
- **Today's dot** glows in gold with a pulse ring
- **Progress bar** showing day number, % complete, days remaining
- **Full customization** (unlockable later):
  - 🎨 Dot colors (past / today / future)
  - 🌅 Background gradient colors
  - 📐 Grid columns (5–25)
  - 📏 Dot size & spacing
  - 🔲 Corner radius (square → circle)
  - ✨ Glow effects toggle
  - 📅 Date label toggle
  - 🎯 Target: Lock Screen / Home Screen / Both
  - 🎨 6 color presets (Space, Green, Sunset, Ocean, Mono, Rose)
- **Export to PNG** — save at 2× resolution for crisp wallpapers
- Works on **Android & iOS**

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10+ SDK
- Dart 3.0+
- Android Studio or Xcode

### Run the app

```bash
cd dotz
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release
```

### Build for iOS

```bash
flutter build ios --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── wallpaper_settings.dart  # Settings model + day calculations
├── screens/
│   ├── home_screen.dart         # Main screen with preview + actions
│   └── customize_screen.dart    # Full customization UI
├── widgets/
│   └── dot_grid_widget.dart     # Core dot grid painter + widget
└── services/
    └── wallpaper_export_service.dart  # PNG export logic
```

---

## 🔧 How to Set as Wallpaper

### Android
1. Tap **Save Wallpaper** in the app
2. Go to **Settings → Wallpaper** (or long-press home screen)
3. Choose from Gallery → find `dotz_wallpaper_*.png`
4. Set as Lock Screen / Home Screen / Both

### iOS
1. Tap **Save Wallpaper** in the app
2. Go to **Settings → Wallpaper → Add New Wallpaper**
3. Select **Photos** → find the saved Dotz image
4. Set as Lock Screen / Home Screen / Both

---

## 🎨 Color Presets

| Preset | Past Dots | Today | Background |
|--------|-----------|-------|------------|
| Space | Purple | Gold | Deep navy |
| Forest | Green | Red | Dark green |
| Sunset | Coral | Gold | Dark rose |
| Ocean | Sky blue | Pink | Deep blue |
| Mono | White | Gray | Black |
| Rose Gold | Pink | Gold | Dark maroon |

---

## 📄 Dependencies

```yaml
flutter_colorpicker: ^1.0.3     # Color picker UI
shared_preferences: ^2.2.2      # Settings persistence
gallery_saver: ^2.3.2           # Save to gallery
path_provider: ^2.1.1           # File system paths
permission_handler: ^11.1.0     # Storage permissions
image: ^4.1.3                   # Image processing
```
