import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

/// Wraps [HoneywellScanner] behind [PdaScanner].
class HoneywellPdaScanner implements PdaScanner, ScannerCallback {
  HoneywellPdaScanner({HoneywellScanner? scanner})
    : _scanner = scanner ?? HoneywellScanner();

  final HoneywellScanner _scanner;
  PdaScannerCallback? _callback;

  @override
  ScannerDeviceType get deviceType => ScannerDeviceType.honeywell;

  @override
  String get deviceLabel => deviceType.label;

  @override
  void setScannerCallback(PdaScannerCallback callback) {
    _callback = callback;
    _scanner.setScannerCallback(this);
  }

  @override
  void onDecoded(ScannedData? scannedData) {
    _callback?.onScanned(ScannedBarcode.fromHoneywell(scannedData));
  }

  @override
  void onError(Exception error) {
    _callback?.onError(error);
  }

  @override
  Future<bool> isSupported() => _scanner.isSupported();

  @override
  Future<bool> isStarted() => _scanner.isStarted();

  @override
  Future<void> setProperties(Map<String, dynamic> properties) {
    return _scanner.setProperties(properties);
  }

  @override
  Future<bool> startScanner() => _scanner.startScanner();

  @override
  Future<bool> stopScanner() => _scanner.stopScanner();

  @override
  Future<bool> pauseScanner() => _scanner.pauseScanner();

  @override
  Future<bool> resumeScanner() => _scanner.resumeScanner();

  @override
  Future<bool> startScanning() => _scanner.startScanning();

  @override
  Future<bool> stopScanning() => _scanner.stopScanning();

  @override
  Future<bool> disposeScanner() => _scanner.disposeScanner();
}
