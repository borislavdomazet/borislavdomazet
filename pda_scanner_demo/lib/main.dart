import 'package:flutter/material.dart';
import 'package:pda_scanner_demo/screens/scan_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PdaScannerApp());
}

class PdaScannerApp extends StatelessWidget {
  const PdaScannerApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDA Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: home ?? const ScanScreen(),
    );
  }
}
