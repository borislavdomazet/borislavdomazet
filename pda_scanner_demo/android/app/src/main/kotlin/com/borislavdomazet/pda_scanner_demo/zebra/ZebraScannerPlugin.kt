package com.borislavdomazet.pda_scanner_demo.zebra

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class ZebraScannerPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {
    companion object {
        const val METHOD_CHANNEL = "pda_scanner_demo/zebra"
        const val EVENT_CHANNEL = "pda_scanner_demo/zebra/scans"
        const val PROFILE_NAME = "PdaScannerDemo"
        const val PROFILE_INTENT_ACTION = "com.borislavdomazet.pda_scanner_demo.SCAN"
        const val DATAWEDGE_ACTION = "com.symbol.datawedge.api.ACTION"
        const val DATAWEDGE_PACKAGE = "com.symbol.datawedge"
        const val EXTRA_DATA_STRING = "com.symbol.datawedge.data_string"
        const val EXTRA_LABEL_TYPE = "com.symbol.datawedge.label_type"
        const val CREATE_PROFILE = "com.symbol.datawedge.api.CREATE_PROFILE"
        const val SET_CONFIG = "com.symbol.datawedge.api.SET_CONFIG"
        const val SOFT_SCAN_TRIGGER = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"
        const val SCANNER_INPUT_PLUGIN = "com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN"
    }

    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var scanReceiver: BroadcastReceiver? = null
    private var started: Boolean = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopScanner()
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
        context = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            "isSupported" -> result.success(isZebraDevice())
            "isStarted" -> result.success(started)
            "startScanner" -> result.success(startScanner())
            "stopScanner" -> result.success(stopScanner())
            "pauseScanner" -> result.success(setScannerEnabled(false))
            "resumeScanner" -> result.success(setScannerEnabled(true))
            "startScanning" -> result.success(softScan("START_SCANNING"))
            "stopScanning" -> result.success(softScan("STOP_SCANNING"))
            "setProperties" -> {
                val properties = call.arguments as? Map<*, *> ?: emptyMap<String, String>()
                result.success(applyDecoderProperties(properties))
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?,
    ) {
        eventSink = events
        registerScanReceiver()
    }

    override fun onCancel(arguments: Any?) {
        unregisterScanReceiver()
        eventSink = null
    }

    private fun startScanner(): Boolean {
        val appContext = context ?: return false
        sendDataWedgeString(CREATE_PROFILE, PROFILE_NAME)
        configureBarcodePlugin(appContext, emptyMap())
        configureIntentOutput(appContext)
        disableKeystrokeOutput(appContext)
        started = setScannerEnabled(true)
        return started
    }

    private fun stopScanner(): Boolean {
        setScannerEnabled(false)
        started = false
        return true
    }

    private fun setScannerEnabled(enabled: Boolean): Boolean {
        sendDataWedgeString(
            SCANNER_INPUT_PLUGIN,
            if (enabled) "ENABLE_PLUGIN" else "DISABLE_PLUGIN",
        )
        started = enabled
        return true
    }

    private fun softScan(command: String): Boolean {
        sendDataWedgeString(SOFT_SCAN_TRIGGER, command)
        return true
    }

    private fun applyDecoderProperties(properties: Map<*, *>): Boolean {
        val appContext = context ?: return false
        val stringProps = LinkedHashMap<String, String>()
        for ((key, value) in properties) {
            if (key != null) {
                stringProps[key.toString()] = value?.toString() ?: ""
            }
        }
        configureBarcodePlugin(appContext, stringProps)
        return true
    }

    private fun configureBarcodePlugin(
        appContext: Context,
        decoderParams: Map<String, String>,
    ) {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", PROFILE_NAME)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "false")

        val barcodeProps = Bundle()
        barcodeProps.putString("scanner_selection", "auto")
        barcodeProps.putString("scanner_input_enabled", "true")
        for ((key, value) in decoderParams) {
            barcodeProps.putString(key, value)
        }
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", appContext.packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))

        sendDataWedgeBundle(SET_CONFIG, profileConfig)
    }

    private fun configureIntentOutput(appContext: Context) {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", PROFILE_NAME)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")

        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", PROFILE_INTENT_ACTION)
        intentProps.putString("intent_delivery", "2")
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", appContext.packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))

        sendDataWedgeBundle(SET_CONFIG, profileConfig)
    }

    private fun disableKeystrokeOutput(appContext: Context) {
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", PROFILE_NAME)
        profileConfig.putString("PROFILE_ENABLED", "true")
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val keystrokeConfig = Bundle()
        keystrokeConfig.putString("PLUGIN_NAME", "KEYSTROKE")
        keystrokeConfig.putString("RESET_CONFIG", "true")

        val keystrokeProps = Bundle()
        keystrokeProps.putString("keystroke_output_enabled", "false")
        keystrokeConfig.putBundle("PARAM_LIST", keystrokeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", keystrokeConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", appContext.packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))

        sendDataWedgeBundle(SET_CONFIG, profileConfig)
    }

    private fun sendDataWedgeString(
        command: String,
        parameter: String,
    ) {
        val appContext = context ?: return
        val intent = Intent()
        intent.action = DATAWEDGE_ACTION
        intent.putExtra(command, parameter)
        appContext.sendBroadcast(intent)
    }

    private fun sendDataWedgeBundle(
        command: String,
        parameter: Bundle,
    ) {
        val appContext = context ?: return
        val intent = Intent()
        intent.action = DATAWEDGE_ACTION
        intent.putExtra(command, parameter)
        appContext.sendBroadcast(intent)
    }

    private fun registerScanReceiver() {
        val appContext = context ?: return
        if (scanReceiver != null) return

        val receiver =
            object : BroadcastReceiver() {
                override fun onReceive(
                    context: Context,
                    intent: Intent,
                ) {
                    if (intent.action != PROFILE_INTENT_ACTION) return
                    val code = intent.getStringExtra(EXTRA_DATA_STRING) ?: return
                    val labelType = intent.getStringExtra(EXTRA_LABEL_TYPE)
                    val payload = HashMap<String, String?>()
                    payload["code"] = code
                    payload["codeType"] = labelType?.removePrefix("LABEL-TYPE-")
                    payload["codeId"] = labelType
                    eventSink?.success(payload)
                }
            }

        val filter = IntentFilter(PROFILE_INTENT_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            appContext.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            appContext.registerReceiver(receiver, filter)
        }
        scanReceiver = receiver
    }

    private fun unregisterScanReceiver() {
        val receiver = scanReceiver ?: return
        try {
            context?.unregisterReceiver(receiver)
        } catch (_: IllegalArgumentException) {
            // Already unregistered.
        }
        scanReceiver = null
    }

    private fun isZebraDevice(): Boolean {
        val appContext = context ?: return false
        val manufacturer = Build.MANUFACTURER.lowercase(Locale.US)
        val brand = Build.BRAND.lowercase(Locale.US)
        val model = Build.MODEL.lowercase(Locale.US)
        if (manufacturer.contains("zebra") || brand.contains("zebra")) return true
        if (manufacturer.contains("motorola") &&
            (model.startsWith("mc") || model.startsWith("tc") || model.startsWith("ec"))
        ) {
            return true
        }
        return isDataWedgeInstalled(appContext)
    }

    private fun isDataWedgeInstalled(appContext: Context): Boolean {
        return try {
            appContext.packageManager.getPackageInfo(DATAWEDGE_PACKAGE, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }
}
