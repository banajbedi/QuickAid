import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/svg.dart';

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

  AudioPlayer player = AudioPlayer();
  int x = 10;
  bool toSend = false;
  void handleTimeout() {
    if (toSend) {
      // to uncomment int response = await sendSOS(long, lat);
      Navigator.pop(context);
      player.stop();
      print("SENT OH YEAH!");
    }
  }

  bool to_call = true;

  @override
  Widget build(BuildContext context) {
    Widget AlertBox() {
      return AlertDialog(
        title: const Center(
            child: Text('Crash Detected!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 50))),
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: SingleChildScrollView(
            child: SizedBox(
          // borderRadius: BorderRadius.all(Radius.circular(32.0)),
          width: 40,
          height: 150,
          child: Center(
              child: Text(
            "Sending Alert in ${x} seconds",
            style: TextStyle(color: Colors.white),
          )),
        )),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                toSend = false;
                Navigator.pop(context, 'Cancel');
              },
              child: Center(
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text('I am OK',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20))),
                ),
              )),
          TextButton(
              onPressed: () async {
                handleTimeout();
                toSend = false;
              },
              child: Center(
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text('Send SOS now!',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20))),
                ),
              )),
        ],
      );
    }

    ;
    void _onPress() {
      int counter = 10;
      toSend = true;
      player.play(AssetSource('sounds/sound.m4a'));
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          x = 10 - timer.tick;
          print(x);
        });
        counter--;
        if (!toSend || counter == 0) {
          print('Cancel timer');
          timer.cancel();
          if (counter == 0) handleTimeout();
          player.stop();
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (ctx) => AlertBox()).then((val) {
          toSend = false;
        });
      });
    }

    if (to_call && accidentDetected) {
      _onPress();
      to_call = false;
    }
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
          'Start Device',
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ignore: sized_box_for_whitespace
              SvgPicture.asset(
                "assets/icons/device.svg",
                height: 250,
                width: 250,
                allowDrawingOutsideViewBox: true,
              ),
                // child: Image.asset('assets/icons/device.svg'),
              // ),
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
                          to_call=true;
                          x=10;
                          accidentDetected=false;
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
