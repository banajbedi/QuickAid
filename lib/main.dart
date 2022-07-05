import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {//async{
  // final prefs = await SharedPreferences.getInstance();
  // String? val = prefs.getString('DEVICE_ID')?? "";
  // bool exist;
  // if(val==null || val=="")
  //   exist=false;
  // else
  //   exist=true;
  // runApp(MyApp(exist: exist,deviceID_stored: val));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  //MyApp({Key? key, required this.exist, required this.deviceID_stored}) : super(key: key);
  // bool exist;
  // String? deviceID_stored;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training Data',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GetInfo(),
    //  home: exist?MyHomePage(title: 'Data', deviceID_input: deviceID_stored):GetInfo(),
    );
  }
}

class GetInfo extends StatefulWidget {
  const GetInfo({Key? key}) : super(key: key);

  @override
  State<GetInfo> createState() => _GetInfoState();
}

class _GetInfoState extends State<GetInfo> {
  TextEditingController userInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 0.3,
          backgroundColor: Colors.black.withOpacity(0.6),
          title: const Center(
              child: Text(
            'QuickAid',
            style: TextStyle(
                fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          ))),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                  width: 500,
                  height: 450,
                  /*decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50.0)),*/
                  child: Image.asset('assets/images/QuickAid.gif')),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: TextFormField(
                controller: userInput,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
                onSaved: (value) {
                  setState(() {
                    userInput.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  focusColor: Colors.white,
                  //add prefix icon
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      "assets/icons/device.svg",
                      height: 30.0,
                      width: 30.0,
                      allowDrawingOutsideViewBox:
                      true,
                    ),
                  ),


                  //errorText: "Error",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.grey,

                  hintText: "DeviceID",

                  //make hint text
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),

                  //create lable
                  labelText: 'DeviceID',
                  //lable style
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "verdana_regular",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                  //minimumSize: Size(100.0,100.0),
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
                onPressed: () async {
                  // obtain shared preferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('DEVICE_ID', userInput.text.toString());
                  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage(title: 'Data', deviceID_input: userInput.text.toString())));
                  },
                child:
                 Text("Next",style: TextStyle(fontWeight: FontWeight.w400)),

            )
            //Text(userInput.text.toString()),
          ],
        ),
      ),
    );
  }

  void checkPreviousSessionAndRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    String val = prefs.getString('DEVICE_ID')?? "";
    if(val!=""){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage(title: 'Data', deviceID_input: val)));
    }
  }
  void initState() {
    super.initState();
    checkPreviousSessionAndRedirect();
  }
}
