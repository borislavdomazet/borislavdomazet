import 'package:pda_scanner_demo/scanners/honeywell_pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/simulated_pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/zebra_pda_scanner.dart';

/// Picks Honeywell, Zebra, or the simulator based on what the device reports.
class ScannerFactory {
  ScannerFactory({
    PdaScanner? honeywellScanner,
    PdaScanner? zebraScanner,
    PdaScanner? simulatedScanner,
  }) : _honeywellScanner = honeywellScanner ?? HoneywellPdaScanner(),
       _zebraScanner = zebraScanner ?? ZebraPdaScanner(),
       _simulatedScanner = simulatedScanner ?? SimulatedPdaScanner();

  final PdaScanner _honeywellScanner;
  final PdaScanner _zebraScanner;
  final PdaScanner _simulatedScanner;

  Future<PdaScanner> create() async {
    if (await _isSupported(_honeywellScanner)) {
      return _honeywellScanner;
    }
    if (await _isSupported(_zebraScanner)) {
      return _zebraScanner;
    }
    return _simulatedScanner;
  }

  Future<bool> _isSupported(PdaScanner scanner) async {
    try {
      return await scanner.isSupported();
    } catch (_) {
      return false;
    }
  }
}
