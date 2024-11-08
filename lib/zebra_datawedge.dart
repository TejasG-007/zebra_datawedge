import 'zebra_datawedge_platform_interface.dart';

class ZebraDataWedge {
  //---------------Scanning Method---------------------//

  //This Method will help to create Data Wedge Profile with Profile Name
  Future<void> createDataWedgeProfile(
      {String profileName = "TejasGProdInternal_2"}) {
    return ZebraDataWedgePlatform.instance
        .createDataWedgeProfile(profileName: profileName);
  }

  //This will give you latest scan data
  Stream<String> get getStreamOfData =>
      ZebraDataWedgePlatform.instance.listenToScannedData;

  //Below method will start scanning
  Future<void> startScan() {
    return ZebraDataWedgePlatform.instance.startScan();
  }

  //This will method will start/listening to stream
  void initialized() {
    return ZebraDataWedgePlatform.instance.initialized();
  }

  //Below method will stop scanning
  Future<void> stopScan() {
    return ZebraDataWedgePlatform.instance.stopScan();
  }

//This method will disable the data wedge
  Future<void> disableDataWedge() {
    return ZebraDataWedgePlatform.instance.disableDataWedge();
  }

  //This method will enable the data wedge
  Future<void> enableDataWedge() {
    return ZebraDataWedgePlatform.instance.enableDataWedge();
  }

  //-------------Printing Methods--------------------------//

  //This method will help connect to printer , where by default its taking 9100 port
  Future<bool> connectToPrinter(String ipAddress,
      {int portNumber = 9100}) async {
    return await ZebraDataWedgePlatform.instance.connectToPrinter(ipAddress);
  }

  //This method will disconnect the printer
  Future<bool> disconnectToPrinter(String ipAddress) async {
    return await ZebraDataWedgePlatform.instance.disconnectToPrinter(ipAddress);
  }

  // This method will help to print the label but make sure to pass label enclosing with \'{label}\'
  Future<bool> printerLabel(String ipAddress, String label) async {
    return await ZebraDataWedgePlatform.instance.printLabel(ipAddress, label);
  }

  //This method will calibrate the printer with calibration command and make sure to pass cmd in enclose \'{cmd}\'
  Future<bool> calibratePrinter(String ipAddress, String command) async {
    return await ZebraDataWedgePlatform.instance
        .calibratePrinter(ipAddress, command);
  }

  //This will take printer ip and return true if printer is available
  Future<bool> isPrinterAvailable(String ipAddress) async {
    return await ZebraDataWedgePlatform.instance.isPrinterAvailable(ipAddress);
  }
}
