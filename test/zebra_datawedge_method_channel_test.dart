import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zebra_scan_datawedge/zebra_datawedge_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelZebraDataWedge platform = MethodChannelZebraDataWedge();
  const MethodChannel channel = MethodChannel('zebra_datawedge');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return "Scanned Data";
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Test Scanners', () async {
    await platform.startScan();
    //  expect(await platform.getPlatformVersion(), '42');
  });
}
