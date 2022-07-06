import 'package:flutter/material.dart';

class Contacts extends StatelessWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
    elevation: 0.3,
        backgroundColor: Colors.black,
        title: const Center(
        child: Text(
        'Contacts     ',
        style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),
    )),),
      body: Text(""),);
  }
}
