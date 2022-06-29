import 'package:flutter/foundation.dart';
class UserData{
  final String? mobile;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? deviceID;

  const UserData({
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.deviceID,
  });

  factory UserData.fromJson(Map<String,dynamic> json){
    return UserData(
      mobile: json['mobile'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      deviceID: json['deviceID'] as String?,
    );
  }
}