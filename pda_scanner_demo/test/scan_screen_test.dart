import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pda_scanner_demo/main.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_device_type.dart';
import 'package:pda_scanner_demo/screens/scan_screen.dart';

import 'fake_pda_scanner.dart';

void main() {
  testWidgets('onScanned writes the barcode into the input field', (
    tester,
  ) async {
    final scanner = FakePdaScanner(
      type: ScannerDeviceType.honeywell,
      label: 'Honeywell',
    );

    await tester.pumpWidget(
      PdaScannerApp(home: ScanScreen(scanner: scanner)),
    );
    await tester.pumpAndSettle();

    expect(scanner.started, isTrue);
    expect(find.byKey(const Key('scanInput')), findsOneWidget);
    expect(find.text('Uređaj: Honeywell'), findsOneWidget);

    scanner.callback?.onScanned(
      const ScannedBarcode(
        code: '5901234123457',
        codeType: 'CODE_128',
        source: ScannerDeviceType.honeywell,
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(TextField, '5901234123457'), findsOneWidget);
  });

  testWidgets('factory falls back to simulator on non-PDA hosts', (
    tester,
  ) async {
    await tester.pumpWidget(const PdaScannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Uređaj: Simulator'), findsOneWidget);
    expect(find.byKey(const Key('scanInput')), findsOneWidget);
  });

  testWidgets('onError shows the error below the input', (tester) async {
    final scanner = FakePdaScanner(type: ScannerDeviceType.zebra);

    await tester.pumpWidget(
      PdaScannerApp(home: ScanScreen(scanner: scanner)),
    );
    await tester.pumpAndSettle();

    scanner.callback?.onError(Exception('scanner claimed'));
    await tester.pump();

    expect(find.textContaining('scanner claimed'), findsOneWidget);
  });
}
