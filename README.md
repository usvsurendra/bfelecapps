# BFELECAPPS

**Blast Furnace Electrical Apps** — A premium Flutter application suite for RINL, Vizag Steel.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

## 📱 Features

- **Drawings App** — Browse BF Electrical drawings with area-wise categorization (BF1, BF2, BF3, BHS, AUX)
- **Motor Details** — Searchable name plate database with advanced filters and Google Sheets sync
- **Shift Snags** — PLC & Hardwire troubleshooting reference with instant search

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.12.2)
- Dart SDK
- Android Studio / VS Code
- Chrome (for web preview)

### Installation

```bash
git clone https://github.com/yourusername/bfelecapps.git
cd bf_elec_apps
flutter pub get
flutter run
```

### Build for Production

```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 🏗️ Project Structure

```
bf_elec_apps/
├── lib/
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── drawings/
│   │   ├── motor_details/
│   │   └── shift_snags/
│   ├── firebase_options.dart
│   └── main.dart
├── assets/
│   ├── motor_data.csv
│   ├── drawings_data.csv
│   └── shift_snags_data.csv
├── pubspec.yaml
└── README.md
```

## 🎨 Design System

- **Theme**: Premium industrial palette (Deep Navy, Steel Blue, Electric Blue, Cyan)
- **Typography**: Inter font family
- **Components**: Material 3 with custom premium styling
- **Responsive**: Mobile-first with tablet/desktop support

## 🔧 Configuration

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place them in respective platform folders
4. Update `firebase_options.dart` with your configuration
5. In the Firebase console go to **Storage** and enable **Cloud Storage for Firebase** (Start in locked mode), then publish the rules below

### Firebase Storage (Profile Photos)

Profile photos are uploaded from the Profile Settings page — camera or gallery on mobile, file picker on desktop/web — and stored at `users/<uid>/profile_photo.jpg`. The download URL is written to the Firebase Auth profile (`photoURL`), so the photo is loaded from Firebase on the next app start and shown in the desktop top bar avatar.

Storage security rules:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/profile_photo.jpg {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

Notes:
- `android/app/google-services.json` and `local.properties` are gitignored; never commit them
- When Firebase is unavailable (for example the web build on GitHub Pages, which ships no Firebase config) the photo is stored locally in `SharedPreferences` instead and the app reports that cloud sync is unavailable

### Google Sheets Integration

The app fetches data from Google Sheets. Update the CSV export URLs in:
- `lib/features/motor_details/data/repositories/motor_repository.dart`
- `lib/features/drawings/data/repositories/drawing_repository.dart`
- `lib/features/shift_snags/data/repositories/shift_snag_repository.dart`

## 📦 Dependencies

- `flutter` — UI framework
- `firebase_core` — Firebase initialization
- `firebase_storage` — Profile photo uploads
- `google_fonts` — Typography
- `http` — Network requests
- `shared_preferences` — Local storage
- `url_launcher` — Open external links

## 📲 Welcome Page and APK Download

`/welcome` is the landing page of the site. It introduces the Blast Furnace Electrical Apps and offers two actions: **Open Web App** (enters the splash and dashboard) and **Download Android App**, which points at `web/downloads/bf-elec-apps-latest.apk`. Because everything under `web/` is copied verbatim into `build/web`, the APK is served straight from GitHub Pages at `/bfelecapps/downloads/bf-elec-apps-latest.apk`.

To publish a newer APK:

```bash
flutter build apk --release --android-skip-build-dependency-validation --target-platform android-arm64
copy /Y build\app\outputs\flutter-apk\app-release.apk web\downloads\bf-elec-apps-latest.apk
git add web/downloads/bf-elec-apps-latest.apk
git commit -m "Update Android APK"
git push origin master
```

Notes:
- Keep the filename `bf-elec-apps-latest.apk` so the link on the welcome page never changes, and bump `WelcomePage.apkVersionLabel` in `lib/features/welcome/presentation/pages/welcome_page.dart` to match `version:` in `bf_elec_apps/pubspec.yaml`
- `android-arm64` covers virtually every current Android device and keeps the download near 34 MB; drop the flag for a universal APK
- Every committed APK stays in git history, so replace the file rather than accumulating versioned copies

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software developed for RINL, Vizag Steel.

## 🔗 Links

- **[Live Demo](https://yourusername.github.io/bfelecapps/)** — GitHub Pages preview
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

<p align="center">Built with ❤️ for RINL, Vizag Steel</p>
