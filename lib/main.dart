import 'dart:async';
import 'package:flutter/material.dart';
import 'package:QuickAid/screens/login_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'screens/ml_page.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickAid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // home: MLPage(
      //   token: "",
      // ),
      home: const LoginScreen(),
    );
  }
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
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
          height: 80,
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
                  child: Center(
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
                  child: Center(
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

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            height: 100,
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                setState(() async {
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
                  showDialog(context: context, builder: (ctx) => AlertBox())
                      .then((val) {
                    toSend = false;
                  });
                });
              },
              child: Center(
                  child: Text(
                "Hello",
                style: TextStyle(color: Colors.black),
              )),
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
