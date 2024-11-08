import 'package:flutter/material.dart';
import 'package:zebra_scan_datawedge/zebra_datawedge.dart';

void main() {
  runApp(const Starter());
}

class Starter extends StatelessWidget {
  const Starter({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final zebraSdk = ZebraDataWedge();

  @override
  void initState() {
    super.initState();
    zebraSdk.initialized();
    zebraSdk.createDataWedgeProfile(profileName: "TejasG_Prod");
  }

  bool connectionStatus = false;
  bool disconnectionStatus = false;
  final printerController = TextEditingController();

  void showSnackBar(Widget widget) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: widget));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zebra SDK Plugin'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: StreamBuilder(
                          stream: zebraSdk.getStreamOfData,
                          builder: (context, snap) {
                            if (snap.hasData) {
                              return Text(
                                snap.data ?? "No Data Available",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              );
                            } else {
                              return const Text(
                                "Scan new data...",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                              );
                            }
                          }),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          TextButton(
                              onPressed: zebraSdk.startScan,
                              child: const Text("Start Scan")),
                          TextButton(
                              onPressed: zebraSdk.stopScan,
                              child: const Text("Stop Scan")),
                        ],
                      ),
                      Column(
                        children: [
                          TextButton(
                              onPressed: zebraSdk.disableDataWedge,
                              child: const Text("Disable Data Wedge")),
                          TextButton(
                              onPressed: zebraSdk.enableDataWedge,
                              child: const Text("Enable Data Wedge")),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: StreamBuilder(
                          stream: zebraSdk.getStreamOfData,
                          builder: (context, snap) {
                            if (snap.hasData) {
                              return Text(
                                snap.data ?? "No Data Available",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Text(
                                "Printer Status :- ${connectionStatus ? "Connected" : disconnectionStatus ? "Disconnected" : "Not Available"}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey),
                              );
                            }
                          }),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        height: 40,
                        width: MediaQuery.sizeOf(context).width / 2,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          cursorHeight: 20,
                          cursorWidth: 1.5,
                          textAlignVertical: TextAlignVertical.center,
                          controller: printerController,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () async {
                                connectionStatus = await zebraSdk
                                    .connectToPrinter(printerController.text);
                                disconnectionStatus = false;
                                setState(() {});
                              },
                              child: const Text("Connect")),
                          TextButton(
                              onPressed: () async {
                                disconnectionStatus =
                                    await zebraSdk.disconnectToPrinter(
                                        printerController.text);
                                connectionStatus = false;
                                setState(() {});
                              },
                              child: const Text("Disconnect")),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () async {
                                final status = await zebraSdk
                                    .isPrinterAvailable(printerController.text);
                                showSnackBar(
                                    Text("Is Printer Available $status"));
                              },
                              child: const Text("isPrinterAvailable")),
                          TextButton(
                              onPressed: () async {
                                final status = await zebraSdk.printerLabel(
                                    printerController.text,"\'^XA\\n^FO100,100^A0N,50,50^FDHi from TejasG Production^FS^XZ\'");// make sure add you calibration command in \'{label}\'
                                showSnackBar(Text("Is Label Printed $status"));
                              },
                              child: const Text("Print-Label")),
                          TextButton(
                              onPressed: () async {
                                final status = await zebraSdk.calibratePrinter(
                                    printerController.text, "\'\'");// make sure add you calibration command in \'{command}\'
                                showSnackBar(Text("Is Calibrated $status"));
                              },
                              child: const Text("Calibrate")),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
