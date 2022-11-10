import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';

class MLPage extends StatefulWidget {
  final String? token;
  const MLPage({Key? key, required this.token}) : super(key: key);
  @override
  _MLPageState createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  bool mlRunning = false;

  @override
  void initState() {}

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
                ElevatedButton(
                  onPressed: () {
                    mlRunning = true;
                    setState(() {});
                  },
                  child: const Text("START QuickAid"),
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    mlRunning = false;
                    setState(() {});
                  },
                  child: const Text("STOP QuickAid"),
                  style: ElevatedButton.styleFrom(primary: Colors.teal),
                )
            ],
          ),
        ),
      ),
    );
  }
}
