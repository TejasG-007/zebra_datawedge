package online.teajsgprod.zebra_datawedge.printing

import android.util.Log
import online.teajsgprod.zebra_datawedge.printing.ZebraPrinterData
import com.zebra.sdk.comm.Connection
import com.zebra.sdk.comm.ConnectionException
import com.zebra.sdk.comm.TcpConnection
import com.zebra.sdk.printer.*
import io.flutter.plugin.common.MethodChannel
import online.teajsgprod.zebra_datawedge.DemoSleeper
import java.io.BufferedReader
import java.io.InputStreamReader

class PrintHelper {

    private val demoSleeper = DemoSleeper()

    //    private var printer: ZebraPrinter? = null
//    private var connection: Connection? = null
    private val printers: ArrayList<ZebraPrinterData> = ArrayList<ZebraPrinterData>()

    //region Printing Functions

    //region Connect a printer with IP address on given port
    fun connectPrinterWithIP(ipAddress: String, portNumber: Int, result: MethodChannel.Result) {
        var connection: Connection? = null
        var printer: ZebraPrinter? = null
        Thread(Runnable {
            try {
                connection = TcpConnection(ipAddress, portNumber)
            } catch (e: NumberFormatException) {
                Log.d("error", "Port Number Is Invalid")
            }

            try {
                connection!!.open()
                Log.d("success", "connected")
            } catch (e: ConnectionException) {
                Log.d("error", "Comm Error! Disconnecting")
                if (connection != null) {
                    connection!!.close()
                }
                demoSleeper.sleep(500)
                result.error("CONNECTION_EXCEPTION", "Connection error", e.message.toString())
            }

            if (connection!!.isConnected) {
                try {
                    Log.d("determine", "Determining printer instance")
                    printer = ZebraPrinterFactory.getInstance(connection)
                    Log.d("determine", "Determining Printer Language")
                    val pl: String = SGD.GET("device.languages", connection)
                    Log.d("connection", "Printer Language $pl")
                } catch (e: ConnectionException) {
                    Log.d("language", "Unknown Printer Language")
                    if (connection != null) {
                        connection!!.close()
                    }
                    printer = null
                    demoSleeper.sleep(500)
                    result.error("CONNECTION_EXCEPTION", "Connection error", e.message.toString())
                } catch (e: ZebraPrinterLanguageUnknownException) {
                    Log.d("language", "Unknown Printer Language")
                    if (connection != null) {
                        connection!!.close()
                    }
                    printer = null
                    demoSleeper.sleep(500)
                    result.error("CONNECTION_EXCEPTION", "Connection error", e.message.toString())
                }
            }

            if (printer != null && connection != null) {
                Log.d("add", "Printer has been added")
                printers.add(ZebraPrinterData(printer!!, connection!!, ipAddress));
                result.success(true)
            }

        }).start()

    }
    //endregion

    //region Disconnect Printer

    fun findPrinterFromIP(ipAddress: String): ZebraPrinterData? {
        return printers.find { data -> data.ip == ipAddress }
    }

    fun disconnect(
        connection: Connection?,
        result: MethodChannel.Result,
        printer: ZebraPrinterData? = null
    ) {
        Thread(Runnable {
            try {
                Log.d("disconnect", "Disconnecting")
                if (connection != null) {
                    connection.close()
                    if (printer != null) {
                        printers.remove(printer)
                    }
                    Log.d("Disconnect", "Disconnected")

                    result.success(true)
                }

            } catch (e: ConnectionException) {
                Log.d("exception", "COMM Error! Disconnected")
                result.error("DISCONNECT_ERROR", "Error in disconnecting printer.", e.message)
            }
        }).start()
    }
    //endregion

    //region Print label from zebra printer

    fun printLabelFromZebraPrinter(
        lblDef: String,
        result: MethodChannel.Result,
        printerData: ZebraPrinterData
    ) {
        Thread(Runnable {
            try {
                if (!printerData.connection.isConnected) {
                    try {
                        printerData.connection.open()
                        Log.d("success", "connected")
                    } catch (e: ConnectionException) {
                        Log.d("error", "Comm Error! Disconnecting")
                        result.error(
                            "CONNECTION_EXCEPTION",
                            "Printer unavailable",
                            e.message.toString()
                        )
                    }
                }
                val linkOsPrinter: ZebraPrinterLinkOs? =
                    ZebraPrinterFactory.createLinkOsPrinter(printerData.printer)
                val printerStatus: PrinterStatus =
                    if (linkOsPrinter != null) linkOsPrinter.currentStatus else printerData.printer.currentStatus
                val configLabel = lblDef.toByteArray() // getConfigLabel(lblDef, printerData)
                if (printerStatus.isReadyToPrint) {
                    try {
                        val response: ByteArray = printerData.connection.sendAndWaitForResponse(
                            configLabel,
                            300,
                            200, "/0"
                        )
                        Log.d("Print response", response.decodeToString())
                        result.success(true)
                    } catch (e: ConnectionException) {
                        Log.d("error in writing", e.message.toString())
                        result.success(false)
                    }
                    Log.d("send data", "Sending Data")
                } else if (printerStatus.isHeadOpen) {
                    Log.d("printer", "Printer Head Open")
                    printerData.connection.write(
                        configLabel
                    )
                    result.error("PRINTER_ERROR", "isHeadOpen", printerStatus.isHeadOpen)
                } else if (printerStatus.isPaused) {
                    Log.d("printer", "Printer is Paused")
                    result.error("PRINTER_ERROR", "isPaused", printerStatus.isHeadOpen)
                } else if (printerStatus.isPaperOut) {
                    printerData.connection.write(
                        configLabel
                    )
                    Log.d("printer", "Printer Media Out")
                    result.error("PRINTER_ERROR", "isPaperOut", printerStatus.isHeadOpen)
                } else {
                    result.error("PRINTER_ERROR", "Connection error", printerStatus.isHeadOpen)
                }
            } catch (e: ConnectionException) {
                Log.d("error", e.message.toString())
                if (e.message.toString() == "Error writing to connection: Broken pipe") {
                    retryConnectionAndPrint(lblDef, printerData, result)
                } else {
                    result.error("CONNECTION_EXCEPTION", "Connection error", e.message.toString())
                }

            }

        }).start()
    }
    //endregion

    //region Configure label definition and convert to ByteArray
    private fun getConfigLabel(labelDef: String, printerData: ZebraPrinterData): ByteArray? {
        var configLabel: ByteArray? = null
        try {
            val printerLanguage = printerData.printer.printerControlLanguage
            SGD.SET("device.languages", "zpl", printerData.connection)
            if (printerLanguage === PrinterLanguage.ZPL) {
                configLabel =
                    labelDef.toByteArray()
            }
        } catch (e: ConnectionException) {
            Log.d("error", e.message.toString())
        }
        return configLabel
    }
    //endregion

    private fun retryConnectionAndPrint(
        lblDef: String,
        printerData: ZebraPrinterData,
        result: MethodChannel.Result
    ) {
        Thread(Runnable {
            try {
                Log.d("disconnect", "Disconnecting")
                printerData.connection.close()
                printers.remove(printerData)

                Log.d("New printer instance", "creating")

                var connection: Connection? = null
                var printer: ZebraPrinter? = null
                try {
                    connection = TcpConnection(printerData.ip, 9100)
                } catch (e: NumberFormatException) {
                    Log.d("error", "Port Number Is Invalid")
                }

                try {
                    connection!!.open()
                    Log.d("success", "connected")
                } catch (e: ConnectionException) {
                    Log.d("error", "Comm Error! Disconnecting")
                    demoSleeper.sleep(500)
                }

                if (connection!!.isConnected) {
                    try {
                        printer = ZebraPrinterFactory.getInstance(connection)
                        print("Determining Printer Language")
                        val pl: String = SGD.GET("device.languages", connection)
                        Log.d("connection", "Printer Language $pl")
                    } catch (e: ConnectionException) {
                        Log.d("language", "Unknown Printer Language")
                        printer = null
                        demoSleeper.sleep(500)
                    } catch (e: ZebraPrinterLanguageUnknownException) {
                        Log.d("language", "Unknown Printer Language")
                        printer = null
                        demoSleeper.sleep(500)
                    }
                }

                if (printer != null) {
                    val newPrinterData = ZebraPrinterData(printer, connection, printerData.ip)
                    printers.add(newPrinterData)
                    printLabelFromZebraPrinter(lblDef, result, newPrinterData)
                }
            } catch (e: ConnectionException) {
                Log.d("exception", "COMM Error! Disconnected")
            }
        }).start()
    }

    fun writeToConnection(
        printerIp: String,
        commandToCalibrate: String,
        result: MethodChannel.Result
    ) {
        val printer = findPrinterFromIP(printerIp)
        Thread(Runnable {
            try {
                val response = printer?.connection?.sendAndWaitForResponse(
                    commandToCalibrate.toByteArray(),
                    300,
                    200, "/0"
                )
                result.success(true)
                //printer?.connection?.write(commandToCalibrate.toByteArray())
            } catch (e: ConnectionException) {
                if (printer != null) {
                    retryConnectionAndPrint(commandToCalibrate, printer, result)
                };
                Log.d("error in calibration", e.message.toString())
                //printer?.connection?.write(commandToCalibrate.toByteArray())
                //result.success(false)
            }
        }).start()
    }

    private fun pingPrinter(ip: String): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("/system/bin/ping -c 1 $ip")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?
            val output = StringBuffer()
            while (reader.readLine().also { line = it } != null) {
                output.append(line)
            }
            reader.close()
            process.waitFor() == 0
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun isPrinterAvailable(ip: String, result: MethodChannel.Result) {
        Thread {
            val isAvailable = pingPrinter(ip)
            result.success(isAvailable)
        }.start()
    }
}