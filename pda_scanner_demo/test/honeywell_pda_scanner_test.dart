import 'package:flutter_test/flutter_test.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:pda_scanner_demo/scanners/honeywell_pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

class _RecordingCallback implements PdaScannerCallback {
  ScannedBarcode? scanned;
  Exception? error;

  @override
  void onScanned(ScannedBarcode data) => scanned = data;

  @override
  void onError(Exception exception) => error = exception;
}

void main() {
  test('forwards Honeywell onDecoded to onScanned', () {
    final callback = _RecordingCallback();
    final scanner = HoneywellPdaScanner();
    scanner.setScannerCallback(callback);

    scanner.onDecoded(
      const ScannedData(code: 'ABC-99', codeId: 'j', codeType: 'Code 128'),
    );

    expect(callback.scanned?.code, 'ABC-99');
    expect(callback.scanned?.codeType, 'Code 128');
    expect(callback.scanned?.source, ScannerDeviceType.honeywell);
  });

  test('forwards Honeywell onError', () {
    final callback = _RecordingCallback();
    final scanner = HoneywellPdaScanner();
    scanner.setScannerCallback(callback);

    scanner.onError(Exception('claim failed'));

    expect(callback.error.toString(), contains('claim failed'));
  });
}
