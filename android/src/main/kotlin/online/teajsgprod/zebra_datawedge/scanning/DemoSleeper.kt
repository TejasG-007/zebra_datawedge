package online.teajsgprod.zebra_datawedge

class DemoSleeper {

    fun sleep(ms: Int) {
        try {
            Thread.sleep(ms.toLong())
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }
    }

}
