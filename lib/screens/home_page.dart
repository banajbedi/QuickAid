import 'package:email_password_login/screens/profile_page.dart';
import 'package:email_password_login/screens/login_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import '../model/profile_format.dart';
import 'contact_page.dart';

class HomePage extends StatefulWidget {
  final String? token;
  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      'Authorization':'Bearer ${widget.token}'
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
      print(widget.token);
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

  Future<int> createDeviceID(String new_deviceID) async {
    var headers = {
      'Authorization':'Bearer ${widget.token}',
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
      return 1;
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

  Future<int> updateDeviceID(String? new_deviceID) async {
    var headers = {
      'Authorization':'Bearer ${widget.token}',
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
      updated_successfully = true;
      updateToast();
      final responseJson = jsonDecode(await response.stream.bytesToString());
      return 1;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ContactPage(token: widget.token)));
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
        automaticallyImplyLeading: false,
        elevation: 0.3,
        backgroundColor: Colors.black,
        title: Text(
                '\t\t\t\t\t\t\t\t\t\tQuickAid',
                style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),
              ),
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)));
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)));
                },
                child: SvgPicture.asset(
                  "assets/icons/profile.svg",
                  height: 50.0,
                  width: 50.0,
                )
            );
          },
        ),
        actions: [
          ActionChip(
              label: Text("Logout"),
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
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
              );
            } else if (snapshot.hasError) {
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
                                      onPressed: () async {
                                          int response = await createDeviceID(_controller_deviceID_create.text);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(token: widget.token)));

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
                                      onPressed: () async {
                                          int response = await updateDeviceID(_controller_deviceID_update.text);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(token: widget.token))
                                        );
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