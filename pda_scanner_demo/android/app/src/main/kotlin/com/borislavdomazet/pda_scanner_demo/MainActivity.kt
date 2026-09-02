package com.borislavdomazet.pda_scanner_demo

import com.borislavdomazet.pda_scanner_demo.zebra.ZebraScannerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(ZebraScannerPlugin())
    }
}
