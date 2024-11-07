package online.teajsgprod.zebra_datawedge

import android.annotation.TargetApi
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import online.teajsgprod.zebra_datawedge.printing.PrintHelper
import org.json.JSONObject

/** ZebraDataWedgePlugin */
class ZebraDatawedgePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var eventSink: EventChannel.EventSink? = null
    private val scanningReceiver = ScanningReceiver()
    private val printerHelper = PrintHelper()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zebra_datawedge")
        channel.setMethodCallHandler(this)
        val eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "online.tejasgprod.scanning")
        eventChannel.setStreamHandler(this)
        scanningReceiver.eventScan = { currentScan: String ->
            eventSink?.success(currentScan)
        }
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "sendDataWedgeCommandStringParameter") {
            val arguments = JSONObject(call.arguments.toString())
            val command: String = arguments.get("command") as String
            val parameter: String = arguments.get("parameter") as String
            sendCommandString(context, command, parameter)
        } else if (call.method == "createDataWedgeProfile") {
            createDataWedgeProfile(call.arguments.toString())
        } else if (call.method == "enableDataWedge") {
            enableDataWedge()
        } else if (call.method == "disableDataWedge") {
            disableDataWedge()
        } else if (call.method == "connectToPrinterWithIP") {
            val arguments = JSONObject(call.arguments.toString())
            val ip: String = arguments.get("printerId") as String
            val port = 9100
            printerHelper.connectPrinterWithIP(ip, port, result)
            //result.success(isConnected)
        } else if (call.method == "printLabel") {
            val arguments = JSONObject(call.arguments.toString())
            val ip: String = arguments.get("printerId") as String
            val labelDef: String = arguments.get("label") as String
            val printer = printerHelper.findPrinterFromIP(ip)
            if (printer != null) {
                printerHelper.printLabelFromZebraPrinter(labelDef, result, printer)
            }
        } else if (call.method == "disconnect") {
            val arguments = JSONObject(call.arguments.toString())
            val ip: String = arguments.get("printerId") as String
            val printer = printerHelper.findPrinterFromIP(ip)
            if (printer != null) {
                val res = printerHelper.disconnect(printer.connection, result, printer)
            }
        } else if (call.method == "isPrinterAvailable") {
            val arguments = JSONObject(call.arguments.toString())
            val ip: String = arguments.get("printerId") as String
            printerHelper.isPrinterAvailable(ip, result)
        } else if (call.method == "calibrate_printer") {
            val arguments = JSONObject(call.arguments.toString())
            val ip: String = arguments.get("printerIp") as String
            val commandToPass: String = arguments.get("command") as String
            printerHelper.writeToConnection(ip, commandToPass, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @TargetApi(Build.VERSION_CODES.TIRAMISU)
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        context.registerReceiver(scanningReceiver, IntentFilter("online.tejasgprod.scanning"),
            Context.RECEIVER_EXPORTED)
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        context.unregisterReceiver(scanningReceiver)
    }

    private fun sendCommandBundle(command: String, parameter: Bundle) {
        val dwIntent = Intent()
        dwIntent.action = DWInterface.DATAWEDGE_SEND_ACTION
        dwIntent.putExtra(command, parameter)
        context.sendBroadcast(dwIntent)
    }

    private fun createDataWedgeProfile(profileName: String) {
        //  Create and configure the DataWedge profile associated with this application
        //  For readability's sake, I have not defined each of the keys in the DWInterface file
        sendCommandString(context, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)
        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", profileName)
        profileConfig.putString("PROFILE_ENABLED", "true") //  These are all strings
        profileConfig.putString("CONFIG_MODE", "UPDATE")
        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "true") //  This is the default but never hurts to specify
        //Barcode Scanner related parameters:
        val barcodeConfigParamList = Bundle()
        barcodeConfigParamList.putString("scanner_selection", "auto")
        barcodeConfigParamList.putString("scanner_input_enabled", "true")
        barcodeConfigParamList.putString("auto_switch_to_default_on_event", "3")
        barcodeConfigParamList.putString("decode_audio_feedback_uri", "") //turn off default scan beeps
        barcodeConfig.putBundle("PARAM_LIST", barcodeConfigParamList)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", context.packageName)      //  Associate the profile with this app
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))
        sendCommandBundle(DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)
        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")
        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")
        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", "online.tejasgprod.scanning")
        intentProps.putString("intent_delivery", "2")  //  "2"
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)
        sendCommandBundle(DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)
    }

    private fun enableDataWedge() {
        val i = Intent()
        i.action = "com.symbol.datawedge.api.ACTION"
        i.putExtra("com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN", "RESUME_PLUGIN")
        // i.putExtra("com.symbol.datawedge.api.ENABLE_DATAWEDGE", true)
        context.sendBroadcast(i)
    }

    private fun disableDataWedge() {
        val i = Intent()
        i.action = "com.symbol.datawedge.api.ACTION"
        //i.putExtra("com.symbol.datawedge.api.ENABLE_DATAWEDGE", false)
        i.putExtra("com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN", "SUSPEND_PLUGIN")
        context.sendBroadcast(i)
    }

    private fun sendCommandString(
        applicationContext: Context?,
        command: String,
        parameter: String
    ) {
        val dwIntent = Intent()
        dwIntent.action = "com.symbol.datawedge.api.ACTION"
        dwIntent.putExtra(command, parameter)
        context.sendBroadcast(dwIntent)
    }
}


