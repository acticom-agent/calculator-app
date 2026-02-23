# Calculator App Monorepo

A cross-platform calculator app with native implementations for Android and iOS.

## Features

- Basic arithmetic: +, −, ×, ÷
- Percentage (%)
- Clear (C) and backspace (⌫)
- Decimal point support
- Clean, modern UI on both platforms

---

## Android

**Stack:** Kotlin, Jetpack Compose, Material 3

### Requirements
- Android Studio Hedgehog+ (or AGP 8.2+)
- JDK 17
- Android SDK 34

### Build & Run
```bash
cd android
./gradlew assembleDebug
# or open in Android Studio and run
```

---

## iOS

**Stack:** Swift, SwiftUI

### Requirements
- Xcode 15+
- iOS 17 SDK

### Build & Run
```bash
cd ios
open Calculator.xcodeproj
# Build & run on simulator or device from Xcode
```

---

## License

MIT
