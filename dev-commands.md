# Flutter Development Commands

## Running App
```bash
# Run in debug mode (with hot reload)
flutter run

# Run in release mode (faster, no hot reload)
flutter run --release

# Run on specific device
flutter run -d chrome
flutter run -d windows
```

## Hot Reload & Restart
```bash
# In running terminal:
r     # Hot Reload (perubahan UI)
R     # Hot Restart (perubahan struktur)
q     # Quit
```

## Clean & Rebuild
```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Clean + Run
flutter clean && flutter pub get && flutter run
```

## Debugging
```bash
# Check for errors
flutter analyze

# Check specific file
flutter analyze lib/pages/nilai_page.dart

# Format code
flutter format lib/

# Show connected devices
flutter devices
```

## Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI (smaller size)
flutter build apk --split-per-abi
```

## Tips
- Gunakan `r` untuk perubahan UI biasa
- Gunakan `R` untuk perubahan struktur/import
- Gunakan `flutter clean` jika ada error aneh
- Save file otomatis trigger hot reload (jika diaktifkan)
