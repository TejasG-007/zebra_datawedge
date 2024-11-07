package online.teajsgprod.zebra_datawedge.printing

import com.zebra.sdk.comm.Connection
import com.zebra.sdk.printer.ZebraPrinter

class ZebraPrinterData(val printer: ZebraPrinter, var connection: Connection, val ip: String)

