import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pda_scanner_demo/scanners/zebra_pda_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pda_scanner_demo/zebra');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps Honeywell properties before sending them to DataWedge', () async {
    final scanner = ZebraPdaScanner();

    await scanner.setProperties({'DEC_CODE128_ENABLED': true});

    expect(calls.single.method, 'setProperties');
    expect(calls.single.arguments['decoder_code128'], 'true');
  });

  test('startScanner asks native DataWedge to start', () async {
    final scanner = ZebraPdaScanner();

    expect(await scanner.startScanner(), isTrue);
    expect(calls.single.method, 'startScanner');
  });
}
