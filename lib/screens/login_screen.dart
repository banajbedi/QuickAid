//import 'package:email_password_login/screens/home_screen.dart';
//import 'package:email_password_login/screens/registration_screen.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_password_login/screens/home_screen.dart';
import 'package:email_password_login/screens/registration_screen.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
Future<UserModel> createUser(String mobile,String password) async
{

  var response = await http.post(Uri.https('shrouded-castle-52205.herokuapp.com', 'api/register/'),body:{
    "mobile":mobile,
    "password":password
  });
  var data = response.body;
  print(data);
/*
  if(response.statusCode==201) {
    String responseString = response.body;
    userModelFromJson(responseString);
  }
  else return null;*/   //-------> token part JWD

}

class _LoginScreenState extends State<LoginScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();
  late UserModel _userModel;
  // editing controller
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  // firebase
  //final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
 // String? errorMessage;

  @override
  Widget build(BuildContext context) {
    //mobile number field
    var mobileNumberField = TextFormField(
        autofocus: false,
        controller: mobileNumberEditingController,
        keyboardType: TextInputType.number,

        validator: (value) {
          RegExp regex = new RegExp(r'^.{10,}$');
          if (value!.isEmpty) {
            return ("Mobile number cannot be Empty");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Mobile number(Min. 10 Numbers)");
          }
          return null;
        },
        onSaved: (value) {
          mobileNumberEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone_iphone),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter Your Mobile Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,

        obscureText: true,
        /*
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Characters)");
          }
        },*/
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,

        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter your Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueAccent,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery
              .of(context)
              .size
              .width,
          onPressed: () async{
            String mobileNumberField = mobileNumberEditingController.text ;
            String passwordField=passwordEditingController.text;
            UserModel data=await createUser(mobileNumberField,passwordField);
            setState(() {
              _userModel=data;
            }

            );

          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 200,
                        child: Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.contain,
                        )),
                    SizedBox(height: 45),
                    mobileNumberField,
                    SizedBox(height: 25),
                    passwordField,
                    SizedBox(height: 35),
                    loginButton,
                    SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen()));
                            },
                            child: Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

