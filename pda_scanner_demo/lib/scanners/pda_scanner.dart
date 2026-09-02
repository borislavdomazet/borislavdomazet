import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

/// Common scanner API used by the UI, regardless of Honeywell or Zebra hardware.
///
/// Method names follow [honeywell_scanner] 8.0.1 so existing Honeywell screens
/// can switch to this interface with a small rename (`onDecoded` → `onScanned`).
abstract class PdaScanner {
  ScannerDeviceType get deviceType;

  String get deviceLabel;

  void setScannerCallback(PdaScannerCallback callback);

  Future<bool> isSupported();

  Future<bool> isStarted();

  Future<void> setProperties(Map<String, dynamic> properties);

  Future<bool> startScanner();

  Future<bool> stopScanner();

  Future<bool> pauseScanner();

  Future<bool> resumeScanner();

  Future<bool> startScanning();

  Future<bool> stopScanning();

  Future<bool> disposeScanner();
}
