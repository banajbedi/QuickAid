import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../model/profile_format.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String? token;
  const ProfilePage({Key? key, required this.token}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //GETTING DATA
  late Future<UserData> futureData;
  //UPDATING DATA
  bool updated_successfully = false;
  @override
  void initState() {
    super.initState();
    //UNCOMMENT
    futureData = fetchUserData();
  }

  Future<UserData> fetchUserData() async {
    var headers = {
      'Authorization':'Bearer ${widget.token}',
     };
    var request = http.Request('GET',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/user/'));
    request.body = '''''';
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(await response.stream.bytesToString());
      return UserData.fromJson(responseJson);
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Data');
    }
  }

  void showToast() => Fluttertoast.showToast(
      msg: updated_successfully?"Updated Successfully":"Failed to Update",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0
  );

  Future<int> updateUserData(String? new_firstName, String? new_lastName,
      String? new_email, String? new_mobile) async {
    var headers = {
      'Authorization':'Bearer ${widget.token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/user/'));
    request.body = json.encode({
      "new_mobile": "$new_mobile",
      "new_firstName": "$new_firstName",
      "new_lastName": "$new_lastName",
      "new_email": "$new_email"
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      updated_successfully = true;
      final responseJson = jsonDecode(await response.stream.bytesToString());
      // print(responseJson);
      // print(UserData.fromJson(responseJson).firstName);
      showToast();
      return 1;
    } else {
      updated_successfully = false;
      showToast();
      throw Exception('Failed to Update Data');
    }
  }

  final double coverHeight = 200;
  final double profileHeight = 144;
  @override
  Widget build(BuildContext context) {
    const TextStyle HeadStyle = TextStyle(
        fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white);
    const TextStyle InfoStyle = TextStyle(fontSize: 20, color: Colors.white);

    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0.1,
              backgroundColor: Colors.transparent,
              leading: BackButton(
                  // label: Text("Go Back"),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => HomePage(token: widget.token)));
                  }),
              title: Center(
                  child: Text(
                "Profile",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FutureBuilder<UserData>(
                                  future: futureData,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        final formkey = GlobalKey<FormState>();
                                        final TextEditingController _controller_email = TextEditingController()..text= "${snapshot.data!.email}";
                                        final TextEditingController _controller_firstName = TextEditingController()..text= "${snapshot.data!.firstName}";
                                        final TextEditingController _controller_lastName = TextEditingController()..text= "${snapshot.data!.lastName}";
                                        final TextEditingController _controller_mobile = TextEditingController()..text= "${snapshot.data!.mobile}";
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0))),
                                          scrollable: true,
                                          title: Center(
                                              child: Text('Update Details')),
                                          content: SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Form(
                                                key: formkey,
                                                child: Column(
                                                  children: <Widget>[
                                                    Visibility(
                                                        visible:
                                                            updated_successfully,
                                                        child: Text(
                                                            updated_successfully
                                                                ? "Updated Successfully!"
                                                                : "")),
                                                    TextFormField(
                                                      validator: (value) {
                                                        RegExp regex = new RegExp(r'^.{3,}$');
                                                        if (value!.isEmpty) {
                                                          return ("First Name cannot be Empty");
                                                        }
                                                        if (!regex.hasMatch(value)) {
                                                          return ("Enter Valid name(Min. 3 Character)");
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (value) {
                                                        _controller_firstName.text = value!;
                                                      },
                                                      controller:
                                                          _controller_firstName,
                                                      decoration: InputDecoration(
                                                        labelText: 'First Name',
                                                        icon: SvgPicture.asset(
                                                          "assets/icons/person.svg",
                                                          height: 30.0,
                                                          width: 30.0,
                                                          allowDrawingOutsideViewBox:
                                                              true,
                                                        ),
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return ("Last Name cannot be Empty");
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (value) {
                                                        _controller_lastName.text = value!;
                                                      },
                                                      controller:
                                                          _controller_lastName,
                                                      decoration: InputDecoration(
                                                        labelText: 'Last Name',
                                                        icon: SvgPicture.asset(
                                                          "assets/icons/transparent.svg",
                                                          height: 30.0,
                                                          width: 30.0,
                                                          allowDrawingOutsideViewBox:
                                                              true,
                                                        ),
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      controller:
                                                          _controller_mobile,
                                                      decoration: InputDecoration(
                                                        labelText: 'Mobile No',
                                                        icon: SvgPicture.asset(
                                                          "assets/icons/phone.svg",
                                                          height: 30.0,
                                                          width: 30.0,
                                                          allowDrawingOutsideViewBox:
                                                              true,
                                                        ),
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
                                                          return ("Please Enter Your Email");
                                                        }
                                                        // reg expression for email validation
                                                        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                                            .hasMatch(value)) {
                                                          return ("Please Enter a valid email");
                                                        }
                                                        return null;
                                                      },
                                                      onSaved: (value) {
                                                        _controller_email.text = value!;
                                                      },
                                                      controller:
                                                          _controller_email,
                                                      decoration: InputDecoration(
                                                        labelText: 'Email Id',
                                                        icon: SvgPicture.asset(
                                                          "assets/icons/email.svg",
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
if(formkey.currentState!.validate())
    {int response = await updateUserData(
    _controller_firstName
        .text,
    _controller_lastName
        .text,
    _controller_email
        .text,
    _controller_mobile
        .text);
    // setState(() {
    //   // futureData = fetchUserData();
    //
    // });
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)));
    }// Navigator.pushReplacement(
                                                    //     context, MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)));
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

                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => ProfilePage()));
                        },
                        child: SvgPicture.asset(
                          "assets/icons/edit.svg",
                          height: 35.0,
                          width: 35.0,
                          //allowDrawingOutsideViewBox: true,
                        ))),
              ],
            ),
            body:
                //COMMENT COLUMN
                // Stack(children: [
                // buildTop(),
                // Container(margin: EdgeInsets.only(top: 240), child: UserInfo())
                // ])
                //UNCOMMENT FUTURE BUILDER
                Container(
              constraints: BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/back.png"),
                    fit: BoxFit.cover),
              ),
              child: FutureBuilder<UserData>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Stack(children: [
                      buildTop(),
                      Container(
                          margin: EdgeInsets.only(top: 240),
                          child:
                              //UserData
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Center(
                                    child: Card(
                                  color: Colors.black54.withOpacity(0.4),
                                  shadowColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34)),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 350,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Row(children: [
                                            Text("First Name : ",
                                                style: HeadStyle),
                                            Text("${snapshot.data!.firstName}",
                                                style: InfoStyle)
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                Center(
                                    child: Card(
                                  color: Colors.black54.withOpacity(0.4),
                                  shadowColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34)),
                                  elevation: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 350,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Row(children: [
                                            Text("Last Name : ",
                                                style: HeadStyle),
                                            Text("${snapshot.data!.lastName}",
                                                style: InfoStyle)
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                Center(
                                    child: Card(
                                  color: Colors.black54.withOpacity(0.4),
                                  shadowColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34)),
                                  elevation: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 350,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Row(children: [
                                            Text("Mobile : ", style: HeadStyle),
                                            Text("${snapshot.data!.mobile}",
                                                style: InfoStyle)
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                Center(
                                    child: Card(
                                  color: Colors.black54.withOpacity(0.4),
                                  shadowColor: Colors.black54,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34)),
                                  elevation: 5,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 350,
                                      height: 60,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Row(children: [
                                            Text("Email Id : ",
                                                style: HeadStyle),
                                            Text(
                                              "${snapshot.data!.email}",
                                              style: InfoStyle,
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                              ]))
                    ]);
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
                },
              ),
            )
            //TO COMMENT TILL ABOVE LINE
            ));
  }

  //My Widgets
  Widget buildTop() {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          //   Container(
          //       margin: EdgeInsets.only(top: 210), child: buildCoverImage()),
          Positioned(top: 85, child: buildProfileImage())
        ]);
  }

  // Widget buildCoverImage() => Container(
  //     child: ClipRRect(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(34), topRight: Radius.circular(34)),
  //         child: Image.asset(
  //           'assets/images/background.jpg',
  //           width: double.infinity,
  //           fit: BoxFit.fitHeight,
  //         )));
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('assets/images/profile.png'),
      );
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

  //COMMENT USER INFO
  // Widget UserInfo() {
  //   const TextStyle HeadStyle = TextStyle(
  //       fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white);
  //   const TextStyle InfoStyle = TextStyle(fontSize: 25, color: Colors.white);
  //   return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
  //     const SizedBox(
  //       height: 20,
  //     ),
  //     Center(
  //         child: Card(
  //       color: Colors.black54.withOpacity(0.4),
  //       shadowColor: Colors.black54,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
  //       child: Container(
  //         // decoration: BoxDecoration(
  //         //   gradient: LinearGradient(
  //         //     colors: [Colors.redAccent,Colors.blue],
  //         //     begin:Alignment.topRight,
  //         //     end:Alignment.bottomCenter,
  //         //   )
  //         // ),
  //         padding: EdgeInsets.all(6),
  //         child: SizedBox(
  //           width: 300,
  //           height: 100,
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Center(
  //               child: Column(children: [
  //                 Text("First Name :", style: HeadStyle),
  //                 Text("rstName}", style: InfoStyle)
  //               ]),
  //             ),
  //           ),
  //         ),
  //       ),
  //     )),
  //     Center(
  //         child: Card(
  //       color: Colors.black54.withOpacity(0.4),
  //       shadowColor: Colors.black54,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
  //       elevation: 5,
  //       child: SizedBox(
  //         width: 300,
  //         height: 100,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Center(
  //             child: Column(children: [
  //               Text("Last Name :", style: HeadStyle),
  //               Text("lastName}", style: InfoStyle)
  //             ]),
  //           ),
  //         ),
  //       ),
  //     )),
  //     Center(
  //         child: Card(
  //       color: Colors.black54.withOpacity(0.4),
  //       shadowColor: Colors.black54,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
  //       elevation: 5,
  //       child: SizedBox(
  //         width: 300,
  //         height: 100,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Center(
  //             child: Column(children: [
  //               Text("Mobile :", style: HeadStyle),
  //               Text("mobile}", style: InfoStyle)
  //             ]),
  //           ),
  //         ),
  //       ),
  //     )),
  //     Center(
  //         child: Card(
  //       color: Colors.black54.withOpacity(0.4),
  //       shadowColor: Colors.black54,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
  //       elevation: 5,
  //       child: SizedBox(
  //         width: 300,
  //         height: 100,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Center(
  //             child: Column(children: [
  //               Text("Email Id :", style: HeadStyle),
  //               Text(
  //                 "mail}",
  //                 style: InfoStyle,
  //               ),
  //             ]),
  //           ),
  //         ),
  //       ),
  //     ))
  //   ]);
  //}
}
