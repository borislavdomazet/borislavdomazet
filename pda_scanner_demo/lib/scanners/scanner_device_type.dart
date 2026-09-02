enum ScannerDeviceType { honeywell, zebra, simulated }

extension ScannerDeviceTypeLabel on ScannerDeviceType {
  String get label {
    switch (this) {
      case ScannerDeviceType.honeywell:
        return 'Honeywell';
      case ScannerDeviceType.zebra:
        return 'Zebra';
      case ScannerDeviceType.simulated:
        return 'Simulator';
    }
  }
}
