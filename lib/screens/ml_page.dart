import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class MLPage extends StatefulWidget {
  final String? token;
  const MLPage({Key? key, required this.token}) : super(key: key);
  @override
  _MLPageState createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  bool mlRunning = false;
  bool accidentDetected = false;
  late final interpreter;

  @override
  initState() {
    getModel();
    super.initState();
  }

  getModel() async {
    interpreter = await tfl.Interpreter.fromAsset('tensorflow_model.tflite');
  }

  runModel() async {
    var input = [
      [
        -6.70260774e-01,
        -9.11243139e-01,
        2.90025806e-01,
        -6.20421507e-02,
        -3.52169650e-01,
        -6.61411915e-01
      ]
    ];

    // if output tensor shape [1,2] and type is float32
    var output = List.filled(1, 0).reshape([-1, 1]);

    // inference
    await interpreter.run(input, output);

    // print the output
    print(output);
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
                        onPressed: () {
                          mlRunning = true;
                          Fluttertoast.showToast(
                              msg: "SUCCESS!\nML model service STARTED.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);
                          // runModel();
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
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
