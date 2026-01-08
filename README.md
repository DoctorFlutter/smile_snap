# Smile Snap 📸

A Flutter package that uses AI (Google ML Kit) to automatically capture photos when a specific facial gesture is detected.

Perfect for selfies, accessibility apps, and hands-free operations.

## Features ✨

* **Smile Detection:** Automatically snaps a photo when the user smiles.
* **Blink Detection:** Trigger capture with a double blink.
* **Wink Detection:** Trigger with a left or right wink.
* **Highly Customizable:** Adjustable thresholds and full UI control.

## Installation 💻

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  smile_snap: ^0.0.1
```
## Setup ⚙️

### Android
Update your `android/app/build.gradle` file to ensure the minimum SDK version is at least 21 (required by ML Kit).

```gradle
defaultConfig {
    // ...
    minSdkVersion 21 
    // ...
}
```
### iOS
Add the following permission to your ios/Runner/Info.plist file so the app can access the camera.
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to detect facial gestures and take photos.</string>
```

## Usage 🛠️

Import the package and use the `SmileSnap` widget in your UI.

```dart
import 'package:smile_snap/smile_snap.dart';
// ... inside your widget tree
SmileSnap(
  trigger: SnapTrigger.smile, // Choose: smile, doubleBlink, blinkLeft...
  onCapture: (File image) {
    // Handle the captured image file here
    print("Photo taken at ${image.path}");
  },
)
```
