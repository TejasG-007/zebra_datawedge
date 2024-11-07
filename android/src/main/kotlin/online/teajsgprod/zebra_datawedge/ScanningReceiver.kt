package online.teajsgprod.zebra_datawedge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.text.SimpleDateFormat
import java.util.Calendar


class ScanningReceiver : BroadcastReceiver() {


    var eventScan: ((String) -> Unit)? = null


    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent != null) {
            if (intent.action.equals("online.tejasgprod.scanning")) {
                //  A barcode has been scanned
                val scanData = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_DATA_STRING)
                val symbology = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_LABEL_TYPE)
                val date = Calendar.getInstance().getTime()
                val df = SimpleDateFormat("dd/MM/yyyy HH:mm:ss")
                val dateTimeString = df.format(date)
                val currentScan = Scan(scanData, symbology, dateTimeString);
                eventScan?.invoke(currentScan.toJson())
            }
        }

    }

}