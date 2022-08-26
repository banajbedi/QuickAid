import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import '../model/contact_format.dart';
import 'home_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ContactPage extends StatefulWidget {
  final String? token;
  const ContactPage({Key? key, required this.token}) : super(key: key);
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //GETTING DATA
  late Future<List<Item>?> contacts;

  static List<String> emergencyContactsName = [];
  static List<String> emergencyContactsInitials = [];
  static List<String> emergencyContactsNo = [];
  static List<String> emergencyContactsRelation = [];
  static List<String> emergencyContactsEmail = [];

  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  final TextEditingController _textFieldController3 = TextEditingController();
  final TextEditingController _textFieldController4 = TextEditingController();

  bool updated_successfully = false;
  bool firstVisit = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emergencyContactsName = [];
    emergencyContactsInitials = [];
    emergencyContactsNo = [];
    emergencyContactsRelation = [];
    emergencyContactsEmail = [];
    refreshContacts();
  }

  void showToast() => Fluttertoast.showToast(
      msg: updated_successfully ? "Success!" : "Failed!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0);

  void getInitial(String name) {
    var nameParts = name.split(" ");
    if (nameParts.length > 1) {
      emergencyContactsInitials
          .add(nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase());
    } else {
      emergencyContactsInitials.add(nameParts[0][0].toUpperCase());
    }
  }

  Future<int> addContact(
      String name, String mobileNumber, String relation, String email) async {
    // dbHelper.add(PersonalEmergency(name, no, relation, email));
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/contacts/'));
    request.body = json.encode({
      "mobile": "$mobileNumber",
      "name": "$name",
      "relation": "$relation",
      "email": "$email"
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      updated_successfully = true;
      // final responseJson = jsonDecode(await response.stream.bytesToString());
      // print(responseJson);
      // print(UserData.fromJson(responseJson).firstName);
      showToast();
      _textFieldController1.clear();
      _textFieldController2.clear();
      _textFieldController3.clear();
      _textFieldController4.clear();
      return 1;
    } else {
      updated_successfully = false;
      showToast();
      throw Exception('Failed to Update Data');
    }
  }

  Future<int> editContact(String newName, String mobileNumber,
      String newMobileNumber, String newRelation, String newEmail) async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/contacts/'));
    request.body = json.encode({
      "mobile": "$mobileNumber",
      "new_mobile": "$newMobileNumber",
      "new_name": "$newName",
      "new_relation": "$newRelation",
      "new_email": "$newEmail"
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print("Success!");
      updated_successfully = true;
      final responseJson = jsonDecode(await response.stream.bytesToString());
      // print(responseJson);
      // print(Item.fromJson(responseJson));
      showToast();
      _textFieldController1.clear();
      _textFieldController2.clear();
      _textFieldController3.clear();
      _textFieldController4.clear();
      return 1;
    } else {
      updated_successfully = false;
      showToast();
      throw Exception('Failed to Update Data');
    }
  }

  Future<int> deleteContact(String mobileNumber) async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('DELETE',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/contacts/'));
    request.body = json.encode({
      "mobile": "$mobileNumber",
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // updated_successfully = true;
      // final responseJson = jsonDecode(await response.stream.bytesToString());
      // print(responseJson);
      // refreshContacts();
      // print(UserData.fromJson(responseJson).firstName);
      // showToast();
      return 1;
    } else {
      // updated_successfully = false;
      // showToast();
      throw Exception('Failed to Delete Data');
    }
  }

  Future<List<Item>> getContacts() async {
    var headers = {
      'Authorization': 'Bearer ${widget.token}',
    };
    var request = http.Request('GET',
        Uri.parse('https://shrouded-castle-52205.herokuapp.com/api/contacts/'));
    request.body = '''''';
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(await response.stream.bytesToString());
      // print(responseJson);

      List<Item> maps = List.from(responseJson)
          .map<Item>((item) => Item.fromMap(item))
          .toList();

      List<Item> contacts = [];
      if (responseJson.isNotEmpty) {
        for (int i = 0; i < responseJson.length; i++) {
          contacts.add(maps[i]);
          // print(maps[i].mobile);
          getInitial(maps[i].name.toString());
          emergencyContactsName.add(maps[i].name.toString());
          emergencyContactsNo.add(maps[i].mobile.toString());
          emergencyContactsRelation.add(maps[i].relation.toString());
          emergencyContactsEmail.add(maps[i].email.toString());
        }
      }
      return contacts;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load Data');
    }
  }

  refreshContacts() {
    setState(() {
      emergencyContactsName = [];
      emergencyContactsInitials = [];
      emergencyContactsNo = [];
      emergencyContactsRelation = [];
      emergencyContactsEmail = [];

      contacts = getContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7ECEF),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.black87,
        leading: BackButton(
            // label: Text("Logout"),
            onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(token: widget.token)));
        }),
        title: Text(
          '\tEmergency Contacts',
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
          future: contacts,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return firstVisit
                  ? (Center(child: loadingIndicator()))
                  : (Center(
                      child: Text(
                      "ContactBook Empty!",
                      style: TextStyle(fontSize: 30),
                    )));
            } else {
              firstVisit = false;
              // getData(snapshot.data);
              return Scrollbar(
                  child: emergencyContactsName.length == 0
                      ? Center(child: Text("ContactBook Empty!"))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: emergencyContactsName.length,
                          itemBuilder: (BuildContext context, index) {
                            return SizedBox(
                                height: 100,
                                child: Card(
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: InkWell(
                                          onTap: () => showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                _textFieldController1.text =
                                                    emergencyContactsName[
                                                        index];
                                                _textFieldController2.text =
                                                    emergencyContactsNo[index];
                                                _textFieldController3.text =
                                                    emergencyContactsRelation[
                                                        index];
                                                _textFieldController4.text =
                                                    emergencyContactsEmail[
                                                        index];
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Edit Contact Details'),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: SizedBox(
                                                        width: 350,
                                                        height: 350,
                                                        child: Column(
                                                          children: [
                                                            TextFormField(
                                                              // controller: _textFieldController1,
                                                              initialValue:
                                                                  emergencyContactsName[
                                                                      index],
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    "Enter Contact Name",
                                                              ),
                                                              onChanged:
                                                                  (name) {
                                                                // print(phone.completeNumber);
                                                                _textFieldController1
                                                                        .text =
                                                                    name;
                                                              },
                                                              onSaved: (value) {
                                                                _textFieldController1
                                                                        .text =
                                                                    value!;
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            IntlPhoneField(
                                                              // controller: _textFieldController2,
                                                              initialValue:
                                                                  emergencyContactsNo[
                                                                          index]
                                                                      .substring(
                                                                          3),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Enter Your Phone Number',
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(),
                                                                ),
                                                              ),
                                                              initialCountryCode:
                                                                  'IN',
                                                              onChanged:
                                                                  (phone) {
                                                                // print(phone.completeNumber);
                                                                _textFieldController2
                                                                        .text =
                                                                    phone
                                                                        .completeNumber;
                                                              },
                                                              onSaved: (value) {
                                                                _textFieldController2
                                                                        .text =
                                                                    value!
                                                                        as String;
                                                              },
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            TextFormField(
                                                              // controller: _textFieldController3,
                                                              initialValue:
                                                                  emergencyContactsRelation[
                                                                      index],
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    "Enter Relation",
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            TextFormField(
                                                              // controller: _textFieldController4,
                                                              initialValue:
                                                                  emergencyContactsEmail[
                                                                      index],
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    "Enter E-mail",
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        _textFieldController1
                                                            .clear();
                                                        _textFieldController2
                                                            .clear();
                                                        _textFieldController3
                                                            .clear();
                                                        _textFieldController4
                                                            .clear();
                                                        Navigator.pop(
                                                            context, 'Cancel');
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        // print(_textFieldController1.text);
                                                        // print(_textFieldController2.text);
                                                        // print(_textFieldController3.text);
                                                        // print(_textFieldController4.text);
                                                        int response = await editContact(
                                                            _textFieldController1
                                                                .text,
                                                            emergencyContactsNo[
                                                                index],
                                                            _textFieldController2
                                                                .text,
                                                            _textFieldController3
                                                                .text,
                                                            _textFieldController4
                                                                .text);
                                                        // refreshContacts(),
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ContactPage(
                                                                        token: widget
                                                                            .token)));
                                                        // Navigator.pushReplacement(
                                                        //     context, MaterialPageRoute(builder: (context) => ContactPage(token: widget.token)));
                                                      },
                                                      child: const Text('Edit'),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          child: ListTile(
                                              title: Text(
                                                emergencyContactsName[index],
                                                style: TextStyle(fontSize: 19),
                                              ),
                                              subtitle: Text(
                                                emergencyContactsNo[index],
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              dense: true,
                                              trailing: Wrap(children: <Widget>[
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  iconSize: 24.0,
                                                  color: Colors.red,
                                                  onPressed: () async {
                                                    int response =
                                                        await deleteContact(
                                                            emergencyContactsNo[
                                                                index]);
                                                    Navigator.pop(context);
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ContactPage(
                                                                    token: widget
                                                                        .token)));
                                                    // Navigator.pushReplacement(
                                                    //     context, MaterialPageRoute(builder: (context) => ContactPage(token: widget.token)));
                                                  },
                                                ),
                                              ]),
                                              leading: CircleAvatar(
                                                  radius: 25,
                                                  child: Text(
                                                    emergencyContactsInitials[
                                                        index],
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  )))),
                                    )));
                          }));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              _textFieldController1.clear();
              _textFieldController2.clear();
              _textFieldController3.clear();
              _textFieldController4.clear();
              return AlertDialog(
                title: const Text('Add Contact Details'),
                content: SingleChildScrollView(
                  child: SizedBox(
                      width: 350,
                      height: 350,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _textFieldController1,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter Contact Name",
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          IntlPhoneField(
                            // controller: _textFieldController2,
                            decoration: InputDecoration(
                              labelText: 'Enter Your Phone Number',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                              ),
                            ),
                            initialCountryCode: 'IN',
                            onChanged: (phone) {
                              // print(phone.completeNumber);
                              _textFieldController2.text = phone.completeNumber;
                            },
                            onSaved: (value) {
                              _textFieldController2.text = value! as String;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          // TextFormField(
                          //   controller: _textFieldController2,
                          //   decoration: const InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     labelText: "Enter Phone No.",
                          //   ),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _textFieldController3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter Relation",
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _textFieldController4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Enter E-mail",
                            ),
                          ),
                        ],
                      )),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      int response = await addContact(
                          _textFieldController1.text,
                          _textFieldController2.text,
                          _textFieldController3.text,
                          _textFieldController4.text);
                      // refreshContacts(),
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ContactPage(token: widget.token)));
                      // Navigator.pushReplacement(
                      //     context, MaterialPageRoute(builder: (context) => ContactPage(token: widget.token)));
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            }),
        tooltip: 'Add Contacts',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget loadingIndicator() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.black,
          size: 100,
        ),
      ),
    );
  }
}
