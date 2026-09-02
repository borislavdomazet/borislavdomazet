import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';
import 'package:pda_scanner_demo/scanners/zebra_property_mapper.dart';

/// DataWedge-backed [PdaScanner] for Zebra devices such as MC3450.
class ZebraPdaScanner implements PdaScanner {
  ZebraPdaScanner({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methods = methodChannel ?? const MethodChannel(_methodChannel),
       _events = eventChannel ?? const EventChannel(_eventChannel);

  static const _methodChannel = 'pda_scanner_demo/zebra';
  static const _eventChannel = 'pda_scanner_demo/zebra/scans';

  final MethodChannel _methods;
  final EventChannel _events;

  PdaScannerCallback? _callback;
  StreamSubscription<dynamic>? _scanSubscription;

  @override
  ScannerDeviceType get deviceType => ScannerDeviceType.zebra;

  @override
  String get deviceLabel => deviceType.label;

  @override
  void setScannerCallback(PdaScannerCallback callback) {
    _callback = callback;
  }

  @override
  Future<bool> isSupported() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _invokeBool('isSupported');
  }

  @override
  Future<bool> isStarted() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return await _invokeBool('isStarted');
  }

  @override
  Future<void> setProperties(Map<String, dynamic> properties) {
    return _methods.invokeMethod<void>(
      'setProperties',
      ZebraPropertyMapper.toDataWedgeParams(properties),
    );
  }

  @override
  Future<bool> startScanner() async {
    _listenForScans();
    return _invokeBool('startScanner');
  }

  @override
  Future<bool> stopScanner() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    return _invokeBool('stopScanner');
  }

  @override
  Future<bool> pauseScanner() => _invokeBool('pauseScanner');

  @override
  Future<bool> resumeScanner() async {
    _listenForScans();
    return _invokeBool('resumeScanner');
  }

  @override
  Future<bool> startScanning() => _invokeBool('startScanning');

  @override
  Future<bool> stopScanning() => _invokeBool('stopScanning');

  @override
  Future<bool> disposeScanner() async {
    _callback = null;
    return stopScanner();
  }

  void _listenForScans() {
    _scanSubscription ??= _events.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          _callback?.onScanned(ScannedBarcode.fromMap(event));
        }
      },
      onError: (Object error) {
        _callback?.onError(error is Exception ? error : Exception('$error'));
      },
    );
  }

  Future<bool> _invokeBool(String method) async {
    try {
      return await _methods.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (error) {
      _callback?.onError(Exception(error.message ?? error.code));
      return false;
    }
  }
}
