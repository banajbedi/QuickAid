// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String mobile;
  String firstName;
  String lastName;
  String email;
  String password;

  UserModel({
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });



  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    mobile: json["mobile"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "mobile": mobile,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
  };
}
