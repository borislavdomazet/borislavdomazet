import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';

/// Vendor-agnostic barcode payload used by [PdaScannerCallback.onScanned].
class ScannedBarcode {
  const ScannedBarcode({
    this.code,
    this.codeId,
    this.codeType,
    this.aimId,
    this.charset,
    this.source = ScannerDeviceType.simulated,
  });

  final String? code;
  final String? codeId;
  final String? codeType;
  final String? aimId;
  final String? charset;
  final ScannerDeviceType source;

  factory ScannedBarcode.fromHoneywell(ScannedData? data) {
    return ScannedBarcode(
      code: data?.code,
      codeId: data?.codeId,
      codeType: data?.codeType,
      aimId: data?.aimId,
      charset: data?.charset,
      source: ScannerDeviceType.honeywell,
    );
  }

  factory ScannedBarcode.fromMap(
    Map<dynamic, dynamic> map, {
    ScannerDeviceType source = ScannerDeviceType.zebra,
  }) {
    return ScannedBarcode(
      code: map['code']?.toString(),
      codeId: map['codeId']?.toString(),
      codeType: map['codeType']?.toString(),
      aimId: map['aimId']?.toString(),
      charset: map['charset']?.toString(),
      source: source,
    );
  }
}
