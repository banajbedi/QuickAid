import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:QuickAid/screens/home_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../model/profile_format.dart';
import 'contact_page.dart';
import 'login_screen.dart';
import 'package:geolocator/geolocator.dart';

class MLPage extends StatefulWidget {
  final String? token, deviceID;
  const MLPage({Key? key, required this.token, required this.deviceID})
      : super(key: key);
  @override
  _MLPageState createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  //Fetching Username
  var data_list = [];

  //Variables for acc, gyro
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double posX = 0, posY = 300;
  bool _flag = false; //Tells about button
  String? message;
  //Variables for position
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  bool created_successfully = false;
  bool updated_successfully = false;
  late Future<UserData> futureData;

  //Variables for date and time
  String? date;
  String? time;

  bool mlRunning = false;
  bool accidentDetected = false;
  String url = '';
  var data;
  var output;

  int count_acc = 0;
  @override
  void initState() {
    checkGps();
    // deviceID = "${widget.deviceID_input}";
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
      var gyroscope =
          _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
      var userAccelerometer = _userAccelerometerValues
          ?.map((double v) => v.toStringAsFixed(1))
          .toList();
    }
    super.initState();
  }

  // fetchData(String url) async {
  //   http.Response response = await http.get(Uri.parse(url));
  //   return response.body;
  // }

  // runModel() async {
  //   var ax = -14.9, ay = -34.5, az = 18.4, gx = -0.1, gy = -0.3, gz = 0.3;
  //   url =
  //       'http://banajbedi.pythonanywhere.com/api?ax=$ax&ay=$ay&az=$az&gx=$gx&gy=$gy&gz=$gz';
  //   return fetchData(url);
  // }

  //DATE AND TIME FUNCTIONS
  getDateTime() {
    date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    time = DateFormat("HH:mm:ss").format(DateTime.now());
  }

  postData(var data_list) async {
    try {
      var response = await http.post(
        Uri.parse("https://paras19sood.pythonanywhere.com/api/"),
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

  checkData() async {
    try {
      final response =
          await http.get(Uri.parse("https://paras19sood.pythonanywhere.com/"));
      final result = json.decode(response.body);
      return result;
    } catch (e) {
      print(e);
    }
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
      var curernt_data = {
        "lat": lat,
        "long": long,
        "deviceID": widget.deviceID,
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
      data_list.add(curernt_data);
      if (await data_list.length == 4) {
        //print(data_list);
        //CALL postData
        postData(data_list);
        data_list.clear();
      }
    }
  }

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

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      // print(position.longitude);
      // print(position.latitude);

      //Final variables are stored here
      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  Future<int> sendSOS(String? long, String? lat) async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('https://paras19sood.pythonanywhere.com/api/sendSOS/'));
    request.body = json.encode({"lat": "$lat", "long": "$long"});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    // print(response);
    if (response.statusCode == 200) {
      updated_successfully = true;
      sosToast();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      print(responseJson);
      return 1;
    } else {
      updated_successfully = false;
      sosToast();
      throw Exception('Failed to Update Data');
    }
  }

  void sosToast() => Fluttertoast.showToast(
      msg: updated_successfully
          ? "SOS sent successfully."
          : "SOS failed to sent.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0);

  AudioPlayer player = AudioPlayer();
  int x = 10;
  bool toSend = false;
  void handleTimeout() async {
    if (toSend) {
      // to uncomment
      // int response = await sendSOS(long, lat);
      Navigator.pop(context);
      player.stop();
      print("SENT OH YEAH!");
    }
  }

  bool to_call = true;

  @override
  Widget build(BuildContext context) {
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    // if (mlRunning) {
    //   getData();
    //   // var response = checkData();
    //   if (message == "Accident") {
    //     accidentDetected = true;
    //   } else {
    //     accidentDetected = false;
    //   }
    // }

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
              fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
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
                          to_call = true;
                          x = 10;
                          accidentDetected = false;
                          mlRunning = true;
                          Fluttertoast.showToast(
                              msg: "SUCCESS!\nML model service STARTED.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          // data = await runModel();
                          // var decodedData = jsonDecode(data);
                          // output = decodedData['output'];
                          // print(output);
                          // postData();
                          // if (output == '1') {
                          accidentDetected = true;
                          // }
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.teal),
                        child: const Text(
                          "START QuickAid (S)",
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
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.teal),
                        child: const Center(
                          child: Text(
                            "STOP QuickAid (S)",
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
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
