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

  UserModel({
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });



  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    mobile: json["mobile"] as String?,
    firstName: json["firstName"] as String?,
    lastName: json["lastName"] as String?,
    email: json["email"] as String?,
    password: json["password"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "mobile": mobile,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "password": password,
  };
}
