import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.deviceID_input})
      : super(key: key);
  final String title;
  String? deviceID_input;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
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

  getGyroAcc(){
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

  @override
  Widget build(BuildContext context) {
    var style_button = ButtonStyle(
      //minimumSize: Size(100.0,100.0),
      backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.4)),
      foregroundColor: MaterialStateProperty.all(Colors.white),

      overlayColor: MaterialStateProperty.all(
          Colors.black.withOpacity(0.5)), // background (button) color

      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        // foreground (text) color
      ),
    );
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    if (_flag == true) {
      getData();
    }
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.greenAccent])),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
        appBar: AppBar(

          elevation: 0.3,
          backgroundColor: Colors.black.withOpacity(0.4),
          title: const Center(
              child: Text(
            "     Data",
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          )),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            TextEditingController _controller_deviceID =
                                TextEditingController()..text = "${deviceID}";
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32.0))),
                              scrollable: true,
                              title: Center(child: Text('Update Device ID')),
                              content: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      TextField(
                                        controller: _controller_deviceID,
                                        decoration: InputDecoration(
                                          labelText: 'Device ID',
                                          icon: SvgPicture.asset(
                                            "assets/icons/device.svg",
                                            height: 30.0,
                                            width: 30.0,
                                            allowDrawingOutsideViewBox: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.white.withOpacity(
                                                0.5)), // background (button) color

                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          // foreground (text) color
                                        ),
                                      ),
                                      child: Text("Submit"),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.remove('DEVICE_ID');
                                        await prefs.setString('DEVICE_ID', _controller_deviceID.text);
                                        setState(() {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyHomePage(
                                                          title: 'Data',
                                                          deviceID_input:
                                                              _controller_deviceID
                                                                  .text)));
                                        });
                                      }),
                                )
                              ],
                            );
                          });
                    },
                    child: SvgPicture.asset(
                      "assets/icons/edit.svg",
                      height: 35.0,
                      width: 35.0,
                      //allowDrawingOutsideViewBox: true,
                    )))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                width: 400,
                height: 520,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(35)),
                child: Column(
                  children: [
                    StreamBuilder<GyroscopeEvent>(
                        stream: SensorsPlatform.instance.gyroscopeEvents,
                        builder: (context, gyroscope) {
                          if (gyroscope.hasData) {
                            posX = posX + (gyroscope.data!.y * 10);
                            posY = posY + (gyroscope.data!.x * 10);
                          }
                          return Transform.translate(
                            offset: Offset(posX, posY),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                            ),
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Device ID :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$deviceID",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Detection:",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$message",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Latitude :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$lat",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Longitude :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$long",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Date :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$date",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Time :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$time",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Accelerometer :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            "$userAccelerometer",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 1,
                      //indent: 20,
                      // endIndent: 0,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Gyroscope :",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 20),
                          ),
                          Spacer(),
                          Text(
                            " $gyroscope",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                //fontStyle: FontStyle.italic,
                                fontFamily: 'Open Sans',
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !_flag,
                    child: ElevatedButton(
                      style: style_button,
                      onPressed: () {
                        _flag = true;
                        print("Started.");
                        setState(() {});
                      },
                      child: Text("START"),
                    ),
                  ),
                  Visibility(
                    visible: _flag,
                    child: ElevatedButton(
                      style: style_button,
                      onPressed: () {
                        _flag = false;
                        print("Stopped.");
                        setState(() {});
                      },
                      child: Text("STOP"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

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
      data_list.add(curernt_data);
      if(await data_list.length==4){
        //print(data_list);
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
  int count_acc=0;
  void initState() {
    checkGps();
    deviceID = "${widget.deviceID_input}";
    if (count_acc==0){_streamSubscriptions.add(
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
        .toList();}
    super.initState();
  }
}
