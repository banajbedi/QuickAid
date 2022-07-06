import 'dart:convert';

// class ContactData{
//   final String? mobile;
//   final String? name;
//   final String? relation;
//   final String? email;
//
//   const ContactData({
//     required this.mobile,
//     required this.name,
//     required this.relation,
//     required this.email,
//   });
//
//   factory ContactData.fromJson(Map<String,dynamic> json){
//     return ContactData(
//       mobile: json['mobile'] as String?,
//       name: json['name'] as String?,
//       relation: json['relation'] as String?,
//       email: json['email'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     var map = <String, dynamic>{'mobile': mobile, 'name': name, 'relation': relation, 'email': email};
//     return map;
//   }
//
//   ContactData.fromMap(Map<dynamic, dynamic> map) {
//     mobile = map['mobile'];
//     name = map['name'];
//     contactNo = map['contactNo'];
//   }
// }



class ContactData {
  static List<Item> items = [];

  Item getByMobile(int mobile) =>
      items.firstWhere((element) => element.mobile == mobile, orElse: null);
}

class Item {
  final String? mobile;
  final String? name;
  final String? relation;
  final String? email;

  Item(
      this.mobile, this.name, this.relation, this.email);

  Item copyWith({
    String? mobile,
    String? name,
    String? relation,
    String? email
  }) {
    return Item(
      mobile ?? this.mobile,
      name ?? this.name,
      relation ?? this.relation,
      email ?? this.email
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mobile': mobile,
      'name': name,
      'relation': relation,
      'email': email
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      map['mobile'],
      map['name'],
      map['relation'],
      map['email']
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Item(id: $mobile, name: $name, relation: $relation, email: $email)';
  }

}
