import 'package:flutter/material.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner.dart';
import 'package:pda_scanner_demo/scanners/pda_scanner_callback.dart';
import 'package:pda_scanner_demo/scanners/scanned_barcode.dart';
import 'package:pda_scanner_demo/scanners/scanner_factory.dart';

/// Single-field scan screen. Implements [PdaScannerCallback.onScanned] the same
/// way Honeywell screens implement [ScannerCallback.onDecoded].
class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.scanner,
    this.scannerFactory,
  });

  /// Injected scanner, used by tests. When null, [scannerFactory] detects the
  /// device and creates Honeywell, Zebra, or simulator.
  final PdaScanner? scanner;

  final ScannerFactory? scannerFactory;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with WidgetsBindingObserver
    implements PdaScannerCallback {
  final TextEditingController _inputController = TextEditingController();

  PdaScanner? _scanner;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachScanner();
  }

  Future<void> _attachScanner() async {
    final scanner =
        widget.scanner ??
        await (widget.scannerFactory ?? ScannerFactory()).create();
    scanner.setScannerCallback(this);
    await scanner.startScanner();
    if (!mounted) {
      await scanner.disposeScanner();
      return;
    }
    setState(() => _scanner = scanner);
  }

  @override
  void onScanned(ScannedBarcode data) {
    if (!mounted) return;
    final code = data.code ?? '';
    setState(() {
      _errorMessage = null;
      _inputController.value = TextEditingValue(
        text: code,
        selection: TextSelection.collapsed(offset: code.length),
      );
    });
  }

  @override
  void onError(Exception error) {
    if (!mounted) return;
    setState(() => _errorMessage = error.toString());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _scanner?.resumeScanner();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _scanner?.pauseScanner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanner?.disposeScanner();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceLabel = _scanner?.deviceLabel ?? '…';
    return Scaffold(
      appBar: AppBar(title: const Text('PDA Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Uređaj: $deviceLabel',
              key: const Key('deviceLabel'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('scanInput'),
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Barkod',
                hintText: 'Skeniraj barkod…',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
