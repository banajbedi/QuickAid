// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String? mobile;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? token;

  UserModel({
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.token
  });



  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    mobile: json["mobile"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    password: json["password"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "mobile": mobile,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
  };
}
