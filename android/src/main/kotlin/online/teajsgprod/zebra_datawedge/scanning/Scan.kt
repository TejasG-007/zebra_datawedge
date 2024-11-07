package online.teajsgprod.zebra_datawedge

import org.json.JSONObject;

class Scan(
    private val data: String?,
    private val symbology: String?,
    private val dateTime: String
) {
    fun toJson(): String {
        return JSONObject(
            mapOf(
                "scanData" to this.data,
                "symbology" to this.symbology,
                "dateTime" to this.dateTime
            )
        ).toString();
    }
}