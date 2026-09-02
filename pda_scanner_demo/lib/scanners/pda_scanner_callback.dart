import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';

/// Same callback pattern as Honeywell's [ScannerCallback], with a vendor-neutral
/// [onScanned] instead of Honeywell-specific [onDecoded].
abstract class PdaScannerCallback {
  void onScanned(ScannedBarcode data);

  void onError(Exception error);
}
