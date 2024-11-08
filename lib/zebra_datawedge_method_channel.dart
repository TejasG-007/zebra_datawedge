import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'zebra_datawedge_platform_interface.dart';

/// An implementation of [ZebraDataWedgePlatform] that uses method channels.
class MethodChannelZebraDataWedge extends ZebraDataWedgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('zebra_datawedge');

  @visibleForTesting
  final scanningChannel = const EventChannel('online.tejasgprod.scanning');

  static const String dwProfile = "TejasGProdInternalProfile";

  @override
  initialized() {
    disableDataWedge();
    scanningChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  StreamController<String> scannedDataStreamController =
      StreamController.broadcast();

  @override
  Future<void> createDataWedgeProfile({String profileName = dwProfile}) async {
    try {
      await methodChannel.invokeMethod("createDataWedgeProfile", profileName);
    } catch (e) {
      print("Error While Creating Data Wedge Profile");
    }
  }

  @override
  Future<void> startScan() async {
    _sendDataWedgeCommand(
        "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
  }

  @override
  Future<void> stopScan() async {
    _sendDataWedgeCommand(
        "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
  }

  @override
  Future<void> disableDataWedge() async {
    try {
      await methodChannel.invokeMethod('disableDataWedge');
    } on PlatformException {
      //  Error invoking Android method
      print('Platform exception while try to disable the data wedge');
    } catch (error) {
      print('Error sending command to dataWedge: ${error.toString()}');
    }
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = "{\"command\":$command,\"parameter\":$parameter}";
      await methodChannel.invokeMethod(
          'sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      //  Error invoking Android method
      print("platform Exception while sending the data");
    } catch (error) {
      print("Error sending command to data wedge: ${error.toString()}");
    }
  }

  @override
  Stream<String> get listenToScannedData => scannedDataStreamController.stream;

  @override
  Future<void> enableDataWedge() async {
    try {
      await methodChannel.invokeMethod('enableDataWedge');
      print('Enabled scanning');
    } on PlatformException {
      print('Platform exception while enabling the data wedge');
    } catch (error) {
      print('Error sending command to dataWedge: ${error.toString()}');
    }
  }

  void _onEvent(event) {
    print(event);
    print("--------------------");
    Map barcodeScan = jsonDecode(event);
    scannedDataStreamController.sink.add(barcodeScan['scanData']);
    var barcodeString = "Barcode: ${barcodeScan['scanData']}";
    var barcodeSymbology = "Symbology: ${barcodeScan['symbology']}";
    var scanTime = "At: ${barcodeScan['dateTime']}";
    print(
        '######## scanned data => $barcodeString, $barcodeSymbology, $scanTime #######');
  }

  void _onError(Object object, StackTrace stackTrace) {
    print("Error object $object, ${stackTrace.toString()}");
    print('Error while receiving the scan result.');
  }

  @override
  Future<bool> connectToPrinter(String ipAddress,
      {int portNumber = 9100}) async {
    try {
      return await methodChannel.invokeMethod("connectToPrinterWithIP",
          {"printerId": ipAddress, "portNumber": portNumber});
    } catch (e) {
      print("There is an issue while connecting to the printer $e");
      return false;
    }
  }

  @override
  Future<bool> disconnectToPrinter(String ipAddress) async {
    try {
      return await methodChannel
          .invokeMethod("disconnect", {"printerId": ipAddress});
    } catch (e) {
      print("There is an issue while disconnecting to the printer $e");
      return false;
    }
  }

  @override
  Future<bool> isPrinterAvailable(String ipAddress) async {
    try {
      return await methodChannel
          .invokeMethod("isPrinterAvailable", {"printerId": ipAddress});
    } catch (e) {
      print("There is an issue while checking printer $e");
      return false;
    }
  }

  @override
  Future<bool> calibratePrinter(String ipAddress, String command) async {
    try {
      return await methodChannel.invokeMethod(
          "calibrate_printer", {"printerId": ipAddress, "command": command});
    } catch (e) {
      print("There is an issue while calibrating the printer $e");
      return false;
    }
  }

  @override
  Future<bool> printLabel(String ipAddress, String label) async {
    try {
      return await methodChannel
          .invokeMethod("printLabel", {"printerId": ipAddress, "label": label});
    } catch (e) {
      print("There is an issue while printing the Label $e");
      return false;
    }
  }
}
