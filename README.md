# ZebraDataWedge Plugin

The `ZebraDataWedge` plugin is a Flutter interface for interacting with Zebra's DataWedge, enabling you to create and configure a DataWedge profile, start/stop scanning, enable/disable DataWedge, and listen to scan data through a stream.

## Features

- **Create a DataWedge Profile**: Easily create a new DataWedge profile with a customizable profile name.
- **Start and Stop Scanning**: Control the scanning process programmatically.
- **Enable or Disable DataWedge**: Toggle DataWedge functionality on Zebra devices.
- **Stream Scanned Data**: Retrieve scanned data via a stream for real-time processing.

## Installation

Add the plugin to your `pubspec.yaml`:

```yaml
dependencies:
  zebra_datawedge: ^1.0.0 # Replace with the actual version
```

Then, install the package:

```bash
flutter pub get
```

## Usage

### Import the Package

```dart
import 'package:zebra_datawedge/zebra_datawedge.dart';
```

### Initialize the Plugin

Create an instance of the `ZebraDataWedge` class:

```dart
final zebraDataWedge = ZebraDataWedge();
```

### Methods

#### 1. `createDataWedgeProfile`

Creates a new DataWedge profile with the specified name.

```dart
await zebraDataWedge.createDataWedgeProfile(profileName: "CustomProfileName");
```

- **Parameters**:
    - `profileName` (optional): The name of the profile. Defaults to `"TejasGProdInternal_2"`.

#### 2. `getStreamOfData`

A stream that provides the latest scan data.

```dart
zebraDataWedge.getStreamOfData.listen((scannedData) {
  print("Scanned Data: $scannedData");
});
```

#### 3. `startScan`

Starts the scanning process.

```dart
await zebraDataWedge.startScan();
```

#### 4. `stopScan`

Stops the scanning process.

```dart
await zebraDataWedge.stopScan();
```

#### 5. `initialized`

Initializes the DataWedge and starts listening to the stream.

```dart
zebraDataWedge.initialized();
```

#### 6. `disableDataWedge`

Disables the DataWedge on the device.

```dart
await zebraDataWedge.disableDataWedge();
```

#### 7. `enableDataWedge`

Enables the DataWedge on the device.

```dart
await zebraDataWedge.enableDataWedge();
```

## Example

```dart
import 'package:zebra_datawedge/zebra_datawedge.dart';

void main() {
  final zebraDataWedge = ZebraDataWedge();

  // Initialize and listen to scanned data
  zebraDataWedge.initialized();
  zebraDataWedge.getStreamOfData.listen((scannedData) {
    print("Scanned Data: $scannedData");
  });

  // Start scanning
  zebraDataWedge.startScan();

  // Stop scanning when done
  zebraDataWedge.stopScan();

  // Enable DataWedge
  zebraDataWedge.enableDataWedge();

  // Disable DataWedge
  zebraDataWedge.disableDataWedge();
}
```

## License

This plugin is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

This `README.md` should provide clear guidance on using the `ZebraDataWedge` plugin. Let me know if you'd like to add any additional information!