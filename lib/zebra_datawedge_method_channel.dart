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
  final eventChannel = const EventChannel('online.tejasgprod.scanning');

  static const String dwProfile = "TejasGProdInternalProfile";

  @override
  initialized() {
    disableDataWedge();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
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
}
