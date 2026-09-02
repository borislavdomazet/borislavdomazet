import 'package:flutter_test/flutter_test.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';
import 'package:pda_scanner_demo/scanners/scanner_factory.dart';

import 'fake_pda_scanner.dart';

void main() {
  test('prefers Honeywell when that device is supported', () async {
    final factory = ScannerFactory(
      honeywellScanner: FakePdaScanner(type: ScannerDeviceType.honeywell),
      zebraScanner: FakePdaScanner(type: ScannerDeviceType.zebra),
      simulatedScanner: FakePdaScanner(),
    );

    final scanner = await factory.create();

    expect(scanner.deviceType, ScannerDeviceType.honeywell);
  });

  test('uses Zebra when Honeywell is not supported', () async {
    final factory = ScannerFactory(
      honeywellScanner: FakePdaScanner(
        supported: false,
        type: ScannerDeviceType.honeywell,
      ),
      zebraScanner: FakePdaScanner(type: ScannerDeviceType.zebra),
      simulatedScanner: FakePdaScanner(),
    );

    final scanner = await factory.create();

    expect(scanner.deviceType, ScannerDeviceType.zebra);
  });

  test('falls back to simulator when no PDA is present', () async {
    final factory = ScannerFactory(
      honeywellScanner: FakePdaScanner(
        supported: false,
        type: ScannerDeviceType.honeywell,
      ),
      zebraScanner: FakePdaScanner(
        supported: false,
        type: ScannerDeviceType.zebra,
      ),
      simulatedScanner: FakePdaScanner(),
    );

    final scanner = await factory.create();

    expect(scanner.deviceType, ScannerDeviceType.simulated);
  });
}
