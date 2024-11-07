import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:zebra_scan_datawedge/zebra_datawedge.dart';
import 'package:zebra_scan_datawedge/zebra_datawedge_method_channel.dart';
import 'package:zebra_scan_datawedge/zebra_datawedge_platform_interface.dart';

class MockZebraDataWedgePlatform
    with MockPlatformInterfaceMixin
    implements ZebraDataWedgePlatform {
  @override
  Future<void> createDataWedgeProfile({String profileName = ""}) {
    throw UnimplementedError();
  }

  @override
  Future<void> disableDataWedge() {
    throw UnimplementedError();
  }

  @override
  Future<void> enableDataWedge() {
    throw UnimplementedError();
  }

  @override
  Stream<String> get listenToScannedData => throw UnimplementedError();

  @override
  Future<void> startScan() {
    throw UnimplementedError();
  }

  @override
  Future<void> stopScan() {
    throw UnimplementedError();
  }

  @override
  void initialized() {}
}

void main() {
  final ZebraDataWedgePlatform initialPlatform =
      ZebraDataWedgePlatform.instance;

  test('$MethodChannelZebraDataWedge is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelZebraDataWedge>());
  });

  test('getPlatformVersion', () async {
    ZebraDataWedge zebraDataWedgePlugin = ZebraDataWedge();
    MockZebraDataWedgePlatform fakePlatform = MockZebraDataWedgePlatform();
    ZebraDataWedgePlatform.instance = fakePlatform;

    //expect(await zebraDataWedgePlugin.getPlatformVersion(), '42');
  });
}
