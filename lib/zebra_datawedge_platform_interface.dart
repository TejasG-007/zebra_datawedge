import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'zebra_datawedge_method_channel.dart';

abstract class ZebraDataWedgePlatform extends PlatformInterface {
  /// Constructs a ZebraDatawedgePlatform.
  ZebraDataWedgePlatform() : super(token: _token);

  static final Object _token = Object();

  static ZebraDataWedgePlatform _instance = MethodChannelZebraDataWedge();

  /// The default instance of [ZebraDataWedgePlatform] to use.
  ///
  /// Defaults to [MethodChannelZebraDataWedge].
  static ZebraDataWedgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZebraDataWedgePlatform] when
  /// they register themselves.
  static set instance(ZebraDataWedgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void initialized() {
    throw UnimplementedError("initialized is not Called");
  }

  Stream<String> get listenToScannedData =>
      throw UnimplementedError("listenToScannedData is Empty");

  Future<void> enableDataWedge() async {
    throw UnimplementedError("enableDataWedge() Method is Not Implemented");
  }

  Future<void> disableDataWedge() async {
    throw UnimplementedError("disableDataWedge() Method is Not Implemented");
  }

  Future<void> startScan() async {
    throw UnimplementedError("startScan() Method is Not Implemented");
  }

  Future<void> stopScan() async {
    throw UnimplementedError("stopScan() Method is Not Implemented");
  }

  Future<void> createDataWedgeProfile({String profileName = ""}) async {
    throw UnimplementedError(
        "createDataWedgeProfile() Method is Not Implemented");
  }

  Future<bool> connectToPrinter(String ipAddress, {int portNumber = 9100}) {
    throw UnimplementedError("connectToPrinter() Method is Not Implemented");
  }

  Future<bool> disconnectToPrinter(String ipAddress) {
    throw UnimplementedError("disconnectToPrinter() Method is Not Implemented");
  }

  Future<bool> isPrinterAvailable(String ipAddress) {
    throw UnimplementedError("isPrinterAvailable() Method is Not Implemented");
  }

  Future<bool> printLabel(String ipAddress, String label) {
    throw UnimplementedError("printLabel() Method is Not Implemented");
  }

  Future<bool> calibratePrinter(String ipAddress, String command) {
    throw UnimplementedError("calibratePrinter() Method is Not Implemented");
  }
}
