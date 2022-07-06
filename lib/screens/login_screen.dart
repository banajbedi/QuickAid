import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:quickaid/screens/registration_screen.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

Future<String?> createUser(String? mobile,String? password) async
{
  var headers = {
    'Content-Type': 'application/json'
  };

  var request = http.Request('POST',
      Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/login/'));
  request.body = json.encode({
    "mobile":mobile,
    "password":password
  });
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  //Token storage
  // Create storage
  final storage = new FlutterSecureStorage();
  if (response.statusCode == 200) {
    // print("Success!");
    final responseJson = jsonDecode(await response.stream.bytesToString());
    // print(responseJson);
    responseJson.forEach((key, value1) async {
      if (key == 'access') {
        await storage.write(key: 'QuickAid_JWT', value: value1);
      }
    });

    // print("Success!");
    String? v2 = await storage.read(key: 'QuickAid_JWT');
    // print(responseJson.keys.toList()[1]);
    // print(responseJson.access);
    // print(v2);
    // print(json.decode(responseJson.body));
    // print("Success!");
    // late UserModel user = UserModel.fromJson(json.decode(responseJson.body));
    // print(user.mobile);
    // print(user.firstName);
    // user.token = v2;
    // print(user.token);
    return v2;
  }
  else {
    print("Error!");
    print(response.reasonPhrase);
    throw Exception('Failed to Login');

  }

}

class _LoginScreenState extends State<LoginScreen> {
  // Create storage
  final storage = new FlutterSecureStorage();
  // form key
  final _formKey = GlobalKey<FormState>();
  // editing controller
  TextEditingController mobileNumberEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  get output => null;
  @override
  Widget build(BuildContext context) {

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
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Enter Your Phone Number',
                        border: OutlineInputBorder(
                        borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        // print(phone.completeNumber);
                        mobileNumberEditingController.text = phone.completeNumber;
                      },
                      onSaved: (value) {
                        mobileNumberEditingController.text = value! as String;
                      },
                      textInputAction: TextInputAction.next,
                    ),

                    SizedBox(height: 25),
                    TextFormField(
                        autofocus: false,
                        controller: passwordEditingController,
                        obscureText: true,
                        validator: (value) {
                          RegExp regex = new RegExp(r'^.{6,}$');
                          if (value!.isEmpty) {
                            return ("Password is required for login");
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Enter Valid Password(Min. 6 Characters)");
                          }
                        },
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
                        )),
                    SizedBox(height: 35),
                    Material(
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
                            String? mobileNumberField = mobileNumberEditingController.text ;
                            String? passwordField = passwordEditingController.text;
                            // print(mobileNumberField);
                            String? v2 = await createUser(mobileNumberField,passwordField);
                            print("Login Success!");
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(token: v2)));
                          },

                          child: Text(
                            "Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          )),
                    ),
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
