/// Maps Honeywell `DEC_*` property keys to DataWedge decoder parameter names.
///
/// Unknown keys are passed through so Zebra-native params still work.
class ZebraPropertyMapper {
  static const Map<String, String> honeywellToDataWedge = {
    'DEC_AZTEC_ENABLED': 'decoder_aztec',
    'DEC_CODABAR_ENABLED': 'decoder_codabar',
    'DEC_CODE39_ENABLED': 'decoder_code39',
    'DEC_CODE93_ENABLED': 'decoder_code93',
    'DEC_CODE128_ENABLED': 'decoder_code128',
    'DEC_DATAMATRIX_ENABLED': 'decoder_datamatrix',
    'DEC_EAN8_ENABLED': 'decoder_ean8',
    'DEC_EAN13_ENABLED': 'decoder_ean13',
    'DEC_MAXICODE_ENABLED': 'decoder_maxicode',
    'DEC_PDF417_ENABLED': 'decoder_pdf417',
    'DEC_QR_ENABLED': 'decoder_qrcode',
    'DEC_RSS_14_ENABLED': 'decoder_gs1_databar',
    'DEC_RSS_EXPANDED_ENABLED': 'decoder_gs1_databar_exp',
    'DEC_UPCA_ENABLE': 'decoder_upca',
    'DEC_UPCE0_ENABLED': 'decoder_upce0',
    'DEC_CODABAR_START_STOP_TRANSMIT': 'decoder_codabar_start_stop',
    'DEC_EAN13_CHECK_DIGIT_TRANSMIT': 'decoder_ean13_check_digit',
  };

  static Map<String, String> toDataWedgeParams(
    Map<String, dynamic> properties,
  ) {
    final mapped = <String, String>{};
    properties.forEach((key, value) {
      final dataWedgeKey = honeywellToDataWedge[key] ?? key;
      if (value is bool) {
        mapped[dataWedgeKey] = value ? 'true' : 'false';
      } else {
        mapped[dataWedgeKey] = '$value';
      }
    });
    return mapped;
  }
}
