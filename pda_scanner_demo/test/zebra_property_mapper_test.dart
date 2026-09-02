import 'package:flutter_test/flutter_test.dart';
import 'package:pda_scanner_demo/scanners/zebra_property_mapper.dart';

void main() {
  test('maps Honeywell decoder flags to DataWedge params', () {
    final mapped = ZebraPropertyMapper.toDataWedgeParams({
      'DEC_CODE128_ENABLED': true,
      'DEC_QR_ENABLED': false,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    });

    expect(mapped['decoder_code128'], 'true');
    expect(mapped['decoder_qrcode'], 'false');
    expect(mapped['decoder_ean13_check_digit'], 'true');
  });

  test('passes through already-mapped DataWedge keys', () {
    final mapped = ZebraPropertyMapper.toDataWedgeParams({
      'decoder_code39': true,
    });

    expect(mapped['decoder_code39'], 'true');
  });
}
