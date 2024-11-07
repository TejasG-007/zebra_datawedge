import 'zebra_datawedge_platform_interface.dart';

class ZebraDataWedge {
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
}
