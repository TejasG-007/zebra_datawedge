# Zebra DataWedge Plugin

This plugin provides a simple interface for interacting with Zebra DataWedge for barcode scanning and label printing functionalities. It includes methods to manage DataWedge profiles, control scanning, and print labels via Zebra printers.

## Features
- **Create and manage DataWedge profiles**
- **Start and stop barcode scanning**
- **Stream scanned data**
- **Connect to Zebra printers (via IP)**
- **Print labels using Zebra printers**
- **Calibrate Zebra printers**

![Example App](https://raw.githubusercontent.com/TejasG-007/assets/refs/heads/main/zebra.png.png)

## Installation

To use the Zebra DataWedge plugin, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  zebra_datawedge: ^<latest_version>
```

Then, run `flutter pub get` to install the package.

## Setup

1. Make sure you have the **Zebra DataWedge** app installed on your Zebra device.
2. Ensure that the necessary permissions are granted for accessing the scanner and printer functionalities.

## Usage

### Initialize DataWedge

Before using any of the DataWedge functionalities, you must initialize the plugin.

```dart
ZebraDataWedge().initialized();
```

### Scanning Methods

1. **Create DataWedge Profile**  
   This method creates a DataWedge profile with the given name. If no name is provided, it defaults to `"TejasGProdInternal_2"`.

   ```dart
   ZebraDataWedge().createDataWedgeProfile(profileName: "MyProfile");
   ```

2. **Start Scanning**  
   This method will start the barcode scanner.

   ```dart
   ZebraDataWedge().startScan();
   ```

3. **Stop Scanning**  
   This method will stop the barcode scanner.

   ```dart
   ZebraDataWedge().stopScan();
   ```

4. **Get Stream of Scanned Data**  
   This method provides a stream that will emit the scanned barcode data as it is scanned by the scanner.

   ```dart
   ZebraDataWedge().getStreamOfData.listen((scannedData) {
     print('Scanned Data: $scannedData');
   });
   ```

5. **Enable DataWedge**  
   Enables the DataWedge service.

   ```dart
   ZebraDataWedge().enableDataWedge();
   ```

6. **Disable DataWedge**  
   Disables the DataWedge service.

   ```dart
   ZebraDataWedge().disableDataWedge();
   ```

### Printer Methods

1. **Connect to Printer**  
   Connect to a Zebra printer using its IP address and an optional port number (default is `9100`).

   ```dart
   bool isConnected = await ZebraDataWedge().connectToPrinter("192.168.1.100");
   ```

2. **Disconnect from Printer**  
   Disconnect from the Zebra printer using its IP address.

   ```dart
   bool isDisconnected = await ZebraDataWedge().disconnectToPrinter("192.168.1.100");
   ```

3. **Print Label**  
   Send a ZPL (Zebra Programming Language) command to the printer to print a label. Make sure to pass the label enclosed in forward slash and  single quotes (`/'`) as shown below.

   ```dart
   bool printed = await ZebraDataWedge().printerLabel("192.168.1.100", "/'^XA^FO100,100^A0N,50,50^FDHello, World!^FS^XZ'/");
   ```

4. **Calibrate Printer**  
   Calibrate the Zebra printer by sending a calibration command. The command must be enclosed in forward slash and single quotes (`/'`).

   ```dart
   bool calibrated = await ZebraDataWedge().calibratePrinter("192.168.1.100", "/'^XA^MMT^XZ'/");
   ```

5. **Check if Printer is Available**  
   This method will check if the printer is available by pinging its IP address.

   ```dart
   bool isAvailable = await ZebraDataWedge().isPrinterAvailable("192.168.1.100");
   ```

## API Methods

### Scanning Methods:
- **`createDataWedgeProfile({String profileName = "TejasGProdInternal_2"})`**: Creates a DataWedge profile with the given profile name.
- **`startScan()`**: Starts the barcode scanning process.
- **`stopScan()`**: Stops the barcode scanning process.
- **`getStreamOfData`**: Stream of data that provides the scanned barcode as a string.
- **`initialized()`**: Initializes the plugin for use.
- **`enableDataWedge()`**: Enables the DataWedge service for scanning.
- **`disableDataWedge()`**: Disables the DataWedge service for scanning.

### Printer Methods:
- **`connectToPrinter(String ipAddress, {int portNumber = 9100})`**: Connects to a Zebra printer using the provided IP address and port number.
- **`disconnectToPrinter(String ipAddress)`**: Disconnects from a Zebra printer.
- **`printerLabel(String ipAddress, String label)`**: Sends a ZPL label to the printer.
- **`calibratePrinter(String ipAddress, String command)`**: Sends a calibration command to the printer.
- **`isPrinterAvailable(String ipAddress)`**: Checks if the printer is available at the provided IP address.

## Example

```dart
void main() async {
  ZebraDataWedge dataWedge = ZebraDataWedge();

  // Initialize DataWedge
  await dataWedge.initialized();

  // Create DataWedge Profile
  await dataWedge.createDataWedgeProfile(profileName: "MyProfile");

  // Start scanning
  await dataWedge.startScan();

  // Listen to scanned data
  dataWedge.getStreamOfData.listen((scannedData) {
    print('Scanned Data: $scannedData');
  });

  // Connect to the printer
  bool connected = await dataWedge.connectToPrinter("192.168.1.100");

  // Print a label
  bool printed = await dataWedge.printerLabel("192.168.1.100", "'^XA^FO100,100^A0N,50,50^FDHello, Zebra!^FS^XZ'");

  // Check if the printer is available
  bool isAvailable = await dataWedge.isPrinterAvailable("192.168.1.100");

  // Calibrate the printer
  bool calibrated = await dataWedge.calibratePrinter("192.168.1.100", "'^XA^MMT^XZ'");

  // Disconnect from the printer
  bool disconnected = await dataWedge.disconnectToPrinter("192.168.1.100");
}
```

## License

This plugin is open-source and available under the [MIT License](LICENSE).