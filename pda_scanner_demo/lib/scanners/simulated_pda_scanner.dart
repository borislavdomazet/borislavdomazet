import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

/// Fallback used on emulators, desktops, and phones without a PDA imager.
///
/// Call [simulateScan] from tests (or a debug hook) to exercise [onScanned].
class SimulatedPdaScanner implements PdaScanner {
  PdaScannerCallback? _callback;
  bool _started = false;

  @override
  ScannerDeviceType get deviceType => ScannerDeviceType.simulated;

  @override
  String get deviceLabel => deviceType.label;

  @override
  void setScannerCallback(PdaScannerCallback callback) {
    _callback = callback;
  }

  void simulateScan(String code, {String codeType = 'CODE_128'}) {
    _callback?.onScanned(
      ScannedBarcode(
        code: code,
        codeType: codeType,
        source: ScannerDeviceType.simulated,
      ),
    );
  }

  void simulateError(Exception error) {
    _callback?.onError(error);
  }

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<bool> isStarted() async => _started;

  @override
  Future<void> setProperties(Map<String, dynamic> properties) async {}

  @override
  Future<bool> startScanner() async {
    _started = true;
    return true;
  }

  @override
  Future<bool> stopScanner() async {
    _started = false;
    return true;
  }

  @override
  Future<bool> pauseScanner() async => true;

  @override
  Future<bool> resumeScanner() async {
    _started = true;
    return true;
  }

  @override
  Future<bool> startScanning() async => _started;

  @override
  Future<bool> stopScanning() async => true;

  @override
  Future<bool> disposeScanner() async {
    _callback = null;
    _started = false;
    return true;
  }
}
