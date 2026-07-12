# AssetSphere

## Intelligent Enterprise Asset and Resource Management System

## Project overview
AssetSphere is an enterprise asset and shared-resource management platform designed to manage asset lifecycles, allocation, transfers, bookings, maintenance, audits, notifications, and operational reports.

## Supported platforms
- Android
- Web
- Windows

## Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Chrome for Flutter Web
- Visual Studio Windows development tools for Windows builds

## Setup commands
```bash
flutter pub get
flutter analyze
```

## How to run Android
```bash
flutter devices
flutter run -d <android-device-id>
```

## How to run Web
```bash
flutter run -d chrome
```

## How to run Windows
```bash
flutter run -d windows
```

## How to build
```bash
flutter build apk --debug
flutter build web
flutter build windows
```

## Current folder architecture
```
lib/
├── app/
├── core/
├── features/
│   ├── allocations/
│   ├── assets/
│   ├── audits/
│   ├── authentication/
│   ├── bookings/
│   ├── dashboard/
│   ├── maintenance/
│   ├── notifications/
│   ├── organization/
│   ├── reports/
│   └── transfers/
├── shared/
└── main.dart
```

## Development status
Flutter foundation completed.
Supabase integration and business modules will be added in later phases.
