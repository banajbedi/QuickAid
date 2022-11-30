import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class MLPage extends StatefulWidget {
  final String? token;
  MLPage({Key? key, required this.token, required this.deviceID_input})
      : super(key: key);

  String? deviceID_input;
  @override
  _MLPageState createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  //FINAL LIST TO SEND
  var data_list = [];

  //Variables for acc, gyro
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double posX = 0, posY = 300;
  bool _flag = false; //Tells about button

  //Variables for position
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  //Variables for date and time
  String? date;
  String? time;

  //Device ID
  String? deviceID;

  String? message;

  bool mlRunning = false;
  bool accidentDetected = false;
  String url = '';
  var data;
  var output;

  //LOCATION FUNCTIONS
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // print(position.longitude);
    // print(position.latitude);

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print(position.longitude);
      print(position.latitude);

      //Final variables are stored here
      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  //DATE AND TIME FUNCTIONS
  getDateTime() {
    date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    time = DateFormat("HH:mm:ss").format(DateTime.now());
  }

  getGyroAcc() {
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }

  // fetchData(String url) async {
  //   http.Response response = await http.get(Uri.parse(url));
  //   return response.body;
  // }

  runModel() {
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    _userAccelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    getData();
    // var ax = -14.9, ay = -34.5, az = 18.4, gx = -0.1, gy = -0.3, gz = 0.3;

    // url =
    //     'http://banajbedi.pythonanywhere.com/api?ax=$ax&ay=$ay&az=$az&gx=$gx&gy=$gy&gz=$gz';

    // return fetchData(url);
  }

  getData() async {
    for (int count = 0; count < 4; count++) {
      if (count != 0) {
        sleep(Duration(milliseconds: 500));
      }

      //GETTING UPDATED DATA
      await getGyroAcc();
      var gyroscope =
          _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
      var userAccelerometer = _userAccelerometerValues
          ?.map((double v) => v.toStringAsFixed(1))
          .toList();

      getDateTime();
      await getLocation();
      var a1 = double.parse(userAccelerometer![0]);
      var a2 = double.parse(userAccelerometer[1]);
      var a3 = double.parse(userAccelerometer[2]);
      var g1 = double.parse(gyroscope![0]);
      var g2 = double.parse(gyroscope[1]);
      var g3 = double.parse(gyroscope[2]);
      var current_data = {
        "lat": lat,
        "long": long,
        "deviceID": deviceID,
        "date": date,
        "time": time,
        "ax": a1,
        "ay": a2,
        "az": a3,
        "gx": g1,
        "gy": g2,
        "gz": g3,
      };
      //NEED TO PUSH DATA
      data_list.add(current_data);
      if (data_list.length == 4) {
        print(data_list);
        //CALL postData
        postData(data_list);
        data_list.clear();
      }
    }
  }

  postData(var data_list) async {
    try {
      var response = await http.post(
        Uri.parse("https://shielded-escarpment-21691.herokuapp.com/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data_list),
      );
      var temp = jsonDecode(response.body);
      setState(() {
        message = temp["message"];
      });
      print("Response is ${response.body}");
    } catch (e) {
      print("FAILED");
      print(e);
    }
  }

  @override
  int count_acc = 0;

  @override
  void initState() {
    checkGps();
    deviceID = "${widget.deviceID_input}";
    if (count_acc == 0) {
      _streamSubscriptions.add(
        gyroscopeEvents.listen(
          (GyroscopeEvent event) {
            setState(() {
              _gyroscopeValues = <double>[event.x, event.y, event.z];
            });
          },
        ),
      );
      _streamSubscriptions.add(
        userAccelerometerEvents.listen(
          (UserAccelerometerEvent event) {
            setState(() {
              _userAccelerometerValues = <double>[event.x, event.y, event.z];
            });
          },
        ),
      );
      _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
      _userAccelerometerValues
          ?.map((double v) => v.toStringAsFixed(1))
          .toList();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mlRunning) {
      runModel();
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
          'ML Page',
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(90, 110, 90, 0),
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
                          // data = await runModel();
                          // var decodedData = jsonDecode(data);
                          // output = decodedData['output'];
                          // print(output);

                          // if (output == '1') {
                          //   accidentDetected = true;
                          // }
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
                "Model Running : $mlRunning",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
