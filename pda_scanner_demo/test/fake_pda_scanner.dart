import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

class FakePdaScanner implements PdaScanner {
  FakePdaScanner({
    this.supported = true,
    this.type = ScannerDeviceType.simulated,
    this.label,
  });

  final bool supported;
  final ScannerDeviceType type;
  final String? label;

  PdaScannerCallback? callback;
  var started = false;
  Map<String, dynamic>? lastProperties;

  @override
  ScannerDeviceType get deviceType => type;

  @override
  String get deviceLabel => label ?? type.label;

  @override
  void setScannerCallback(PdaScannerCallback callback) {
    this.callback = callback;
  }

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> isStarted() async => started;

  @override
  Future<void> setProperties(Map<String, dynamic> properties) async {
    lastProperties = properties;
  }

  @override
  Future<bool> startScanner() async {
    started = true;
    return true;
  }

  @override
  Future<bool> stopScanner() async {
    started = false;
    return true;
  }

  @override
  Future<bool> pauseScanner() async => true;

  @override
  Future<bool> resumeScanner() async {
    started = true;
    return true;
  }

  @override
  Future<bool> startScanning() async => started;

  @override
  Future<bool> stopScanning() async => true;

  @override
  Future<bool> disposeScanner() async {
    callback = null;
    started = false;
    return true;
  }
}
