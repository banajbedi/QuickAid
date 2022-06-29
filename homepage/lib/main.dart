import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'screens/contacts.dart';
import 'package:homepage/screens/profile_page.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:homepage/services/profile_format.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      home: MyHomePage(),
      theme: ThemeData(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Fetching Username
  bool created_successfully = false;
  bool updated_successfully = false;
  late Future<UserData> futureData;
  @override
  void initState() {
    super.initState();
    //UNCOMMENT
    futureData = fetchUserData();
  }

  Future<UserData> fetchUserData() async {
    var headers= {
      'Authorization':'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU2NTc5MzI4LCJqdGkiOiIwMjIxZDFmNDRjN2M0NWE1OWJjYzM2YzE3ZGQ2ZTEwZSIsInVzZXJfaWQiOiJiMWYxNGM2MC1mMmU5LTRmMjMtYmZmNC00NDEyZjdiOTliNWIifQ.8bVfxWmIeUa7xZkZDPruxyF11XNEkboYvVbHOX_lBis',
    };
    var request =http.Request('GET',Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/user/'));
    request.body ='''''';
    request.headers.addAll(headers);
    http.StreamedResponse response= await request.send();

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(await response.stream.bytesToString());
      return UserData.fromJson(responseJson);
    }
    else {
      print(response.statusCode);
      throw Exception('Failed to load Data');
    }
  }

  void createdToast() => Fluttertoast.showToast(
      msg: created_successfully?"Created Successfully":"Failed to Create",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0
  );
  Future<UserData> createDeviceID(String new_deviceID) async {
    var headers = {
      'Authorization':'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU2NTc5MzI4LCJqdGkiOiIwMjIxZDFmNDRjN2M0NWE1OWJjYzM2YzE3ZGQ2ZTEwZSIsInVzZXJfaWQiOiJiMWYxNGM2MC1mMmU5LTRmMjMtYmZmNC00NDEyZjdiOTliNWIifQ.8bVfxWmIeUa7xZkZDPruxyF11XNEkboYvVbHOX_lBis',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/user/'));
    request.body = json.encode({
      "deviceID": "$new_deviceID",
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      created_successfully = true;
      createdToast();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      return UserData.fromJson(responseJson);
    } else {
      created_successfully=false;
      createdToast();
      throw Exception('Failed to Create Device');
  }}

  void updateToast() => Fluttertoast.showToast(
      msg: updated_successfully?"Updated Successfully":"Failed to update",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0
  );
  Future<UserData> updateDeviceID(String? new_deviceID) async {
    var headers = {
      'Authorization':'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjU2NTc5MzI4LCJqdGkiOiIwMjIxZDFmNDRjN2M0NWE1OWJjYzM2YzE3ZGQ2ZTEwZSIsInVzZXJfaWQiOiJiMWYxNGM2MC1mMmU5LTRmMjMtYmZmNC00NDEyZjdiOTliNWIifQ.8bVfxWmIeUa7xZkZDPruxyF11XNEkboYvVbHOX_lBis',
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/user/'));
    request.body = json.encode({
      "deviceID": "$new_deviceID",
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      updated_successfully = true;
      updateToast();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      return UserData.fromJson(responseJson);
    } else {
      updated_successfully = false;
      updateToast();
      throw Exception('Failed to Update Data');
    }
  }


  //My Variables
  int _selectedIndex = 0;
  bool isPressed1 = false;
  bool isPressed2 = false;
  bool connection_status = false;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Contacts()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFE7ECEF);
    const TextStyle HeadStyle = TextStyle(
        fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.black,
        title: const Center(
            child: Text(
          '      QuickAid',
          style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),
        )),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: SvgPicture.asset(
                    "assets/icons/profile.svg",
                    height: 50.0,
                    width: 50.0,
                    //allowDrawingOutsideViewBox: true,
                  ))),
        ],
      ),
      body:
        //comment here
    FutureBuilder<UserData>(
    future: futureData,
    builder: (context, snapshot) {
    if (snapshot.hasData) {
      if(snapshot.data!.deviceID!= null){
        connection_status=true;
      }
    return
      // till here
      SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
            // ),
            Center(
                child: Text(
                //Escape data here
              "Welcome ${snapshot.data!.firstName} ",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            )),
            DeviceImage(),
            DeviceStatusText(),
        Center(
          child: Text(
            connection_status ? "${snapshot.data!.deviceID}" : "Not Connected",
            style: TextStyle(
              fontSize: 25,
              color: connection_status ? Colors.green : Colors.redAccent,
            ),
          ),
        ),
            DeviceButton(connection_status)
          ],
        )),
      )
    //then from here
    ; } else if (snapshot.hasError) {
    return SafeArea(
    child: Container(
    margin: EdgeInsets.all(10),
    child: Center(
    child: Text('${snapshot.error}', style: HeadStyle)),
    ));
    }
    // By default, show a loading spinner.
    return loadingIndicator();
    },),//till here
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/home.svg",
              height: 30.0,
              width: 30.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/sos2.svg",
              height: 40.0,
              width: 40.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'SOS',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/contacts.svg",
              height: 40.0,
              width: 40.0,
              allowDrawingOutsideViewBox: true,
            ),
            label: 'Contacts',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
  //My Widgets
  Widget DeviceImage(){
    return SvgPicture.asset(
    "assets/icons/device.svg",
    height: 250.0,
    width: 250.0,
    allowDrawingOutsideViewBox: true,
    );
  }
  Widget DeviceStatusText(){
    return Center(
      child: Text(
        connection_status ?"Device Id :":"Device Status :",
        style: TextStyle(
            fontSize: 35,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      ),
    );}

  Widget DeviceButton(bool connection_status){
    final TextEditingController _controller_deviceID_create = TextEditingController();
    final TextEditingController _controller_deviceID_update = TextEditingController();
    final backgroundColor = const Color(0xFFE7ECEF);
    Offset distance1 = isPressed1 ? Offset(10, 10) : Offset(28, 28);
    double blur1 = isPressed1 ? 5.0 : 30.0;
    Offset distance2 = isPressed2 ? Offset(10, 10) : Offset(28, 28);
    double blur2 = isPressed2 ? 5.0 : 30.0;
    return Stack(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Visibility(
            visible: !connection_status,
            child: Listener(
              onPointerUp: (_) => setState((){ isPressed1 = false;
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<UserData>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.done) {
                if (snapshot.hasData) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(32.0))),
                    scrollable: true,
                    title: Center(
                        child: Text('Create Device')),
                    content: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                          TextField(
                            //UNCOMMENT
                          controller:
                          _controller_deviceID_create,

                          decoration: InputDecoration(
                            labelText: 'Device ID',
                            icon: SvgPicture.asset(
                              "assets/icons/device.svg",
                              height: 30.0,
                              width: 30.0,
                              allowDrawingOutsideViewBox:
                              true,
                            ),
                          ),
                        ),
                        ],
                      ),
                  ),
              ),
                    ),
              actions: [
              Center(
              child: ElevatedButton(
              style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty
                  .all(Colors.black),
              foregroundColor:
              MaterialStateProperty
                  .all(Colors.white),
              overlayColor:
              MaterialStateProperty
                  .all(Colors.white
                  .withOpacity(
              0.5)), // background (button) color

              shape: MaterialStateProperty
                  .all(
              RoundedRectangleBorder(
              borderRadius:
              BorderRadius
                  .circular(25),
              ),
              // foreground (text) color
              ),
              ),
              child: Text("Submit"),
              onPressed: () {
              setState(() {
                futureData = createDeviceID(_controller_deviceID_create.text);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
              });
              }),
              )
              ],
              );
              } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
              }
            }

              return loadingIndicator();
            },
          );
        });
  }),
              onPointerDown: (_) => setState(() => isPressed1 = true),
              child: AnimatedContainer(
                width: 150.0,
                height: 150.0,
                color: backgroundColor,
                alignment: Alignment.center,
                transformAlignment: Alignment.center,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 220,
                  height: 120,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/add.svg",
                          height: 50.0,
                          width: 50.0,
                          //allowDrawingOutsideViewBox: true,
                        ),
                        Text(
                          'Add Device',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ]),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(21),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xffcbcaca),
                        Color(0xffffffff),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffffffff),
                        offset: distance1,
                        blurRadius: blur1,
                        inset: isPressed1,
                      ),
                      BoxShadow(
                        color: Color(0xffcbcaca),
                        offset: distance1,
                        blurRadius: blur1,
                        inset: isPressed1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Visibility(
            visible: connection_status,
            maintainSize: false,
            maintainAnimation: false,
            maintainState: false,
            child: Listener(
              onPointerUp: (_) => setState((){ isPressed1 = false;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder<UserData>(
                      future: futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.done) {
                          if (snapshot.hasData) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(32.0))),
                              scrollable: true,
                              title: Center(
                                  child: Text('Update Device ID')),
                              content: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    child: Column(
                                      children: <Widget>[
                                        TextField(
                                          //UNCOMMENT CONTROLLER
                                         controller:
                                          _controller_deviceID_update,

                                    decoration: InputDecoration(
                                            labelText: 'Device ID',
                                            icon: SvgPicture.asset(
                                              "assets/icons/device.svg",
                                              height: 30.0,
                                              width: 30.0,
                                              allowDrawingOutsideViewBox:
                                              true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty
                                            .all(Colors.black),
                                        foregroundColor:
                                        MaterialStateProperty
                                            .all(Colors.white),
                                        overlayColor:
                                        MaterialStateProperty
                                            .all(Colors.white
                                            .withOpacity(
                                            0.5)), // background (button) color

                                        shape: MaterialStateProperty
                                            .all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(25),
                                          ),
                                          // foreground (text) color
                                        ),
                                      ),
                                      child: Text("Submit"),
                                      onPressed: () {
                                        setState(() {
                                          futureData=updateDeviceID(_controller_deviceID_update.text);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));

                                        });
                                      }),
                                )
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                        }

                        return loadingIndicator();
                      },
                    );
                  });
              }),
              onPointerDown: (_) => setState(() => isPressed1 = true),
              child: AnimatedContainer(
                width: 150.0,
                height: 150.0,
                color: backgroundColor,
                alignment: Alignment.center,
                transformAlignment: Alignment.center,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 220,
                  height: 120,
                  child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/edit.svg",
                          height: 50.0,
                          width: 50.0,
                          //allowDrawingOutsideViewBox: true,
                        ),
                        Text(
                          'Edit Device',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ]),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(21),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xffcbcaca),
                        Color(0xffffffff),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffffffff),
                        offset: distance2,
                        blurRadius: blur2,
                        inset: isPressed1,
                      ),
                      BoxShadow(
                        color: Color(0xffcbcaca),
                        offset: distance2,
                        blurRadius: blur2,
                        inset: isPressed1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget loadingIndicator() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.black,
          size: 100,
        ),
      ),
    );
  }
}

//Device Info Widget

// Listener(
//   onPointerUp: (_) => setState(() {
//     isPressed2 = false;
//     showModalBottomSheet(
//         context: context,
//         //isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(25))
//         ),
//         builder: (context) => Column(
//           //mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Text(connection_status ?'Devie ID:':'Please Connect Device',style: optionStyle),
//               Text(connection_status ?'$deviceID':''),
//               ElevatedButton(
//                 child: Text('Close'),
//                 onPressed: () => Navigator.pop(context),
//               ),]
//         )
//     );
//   }),
//   onPointerDown: (_) => setState(() => isPressed2 = true),
//   child: AnimatedContainer(
//     width: 150.0,
//     height: 150.0,
//     color: backgroundColor,
//     alignment: Alignment.center,
//     transformAlignment: Alignment.center,
//     duration: const Duration(milliseconds: 100),
//     child: Container(
//       width: 120,
//       height: 100,
//       child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Icon(
//               Icons.info_outline,
//               size: 49,
//               color: Colors.indigo,
//             ),
//             Text(
//               'Device Info',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             )
//           ]),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(21),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xffcbcaca),
//             Color(0xffffffff),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xffffffff),
//             offset: distance2,
//             blurRadius: blur2,
//             inset: isPressed2,
//           ),
//           BoxShadow(
//             color: Color(0xffcbcaca),
//             offset: distance2,
//             blurRadius: blur2,
//             inset: isPressed2,
//           ),
//         ],
//       ),
//     ),
//   ),
// ),