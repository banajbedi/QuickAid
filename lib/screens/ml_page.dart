import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class MLPage extends StatefulWidget {
  final String? token;
  const MLPage({Key? key, required this.token}) : super(key: key);
  @override
  _MLPageState createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  bool mlRunning = false;
  bool accidentDetected = false;
  String url = '';
  var data;
  var output;

  @override
  initState() {
    super.initState();
  }

  fetchData(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    return response.body;
  }

  runModel() async {
    var ax = -14.9, ay = -34.5, az = 18.4, gx = -0.1, gy = -0.3, gz = 0.3;

    url =
        'http://banajbedi.pythonanywhere.com/api?ax=$ax&ay=$ay&az=$az&gx=$gx&gy=$gy&gz=$gz';

    return fetchData(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.black87,
        leading: BackButton(onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(token: widget.token)));
        }),
        title: const Text(
          'ML Page',
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80),
          color: Colors.grey[800],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ignore: sized_box_for_whitespace
              Container(
                height: 200,
                width: 200,
                child: Image.asset('assets/logo.png'),
              ),
              const SizedBox(
                height: 100,
              ),

              if (!mlRunning)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () async {
                          mlRunning = true;
                          Fluttertoast.showToast(
                              msg: "SUCCESS!\nML model service STARTED.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          data = await runModel();
                          var decodedData = jsonDecode(data);
                          output = decodedData['output'];
                          print(output);

                          if (output == '1') {
                            accidentDetected = true;
                          }
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.teal),
                        child: const Text(
                          "START QuickAid",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          mlRunning = false;
                          accidentDetected = false;
                          Fluttertoast.showToast(
                              msg: "ML model service STOPPED.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.teal),
                        child: const Center(
                          child: Text(
                            "STOP QuickAid",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              Text(
                "Accident Detected : $accidentDetected",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
