import 'dart:convert';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';

class RequestProfilePage extends StatefulWidget {
  final String role;
  final String profilePicture;
  final String userName;
  final String emailID;
  final String grade;
  final String division;
  final String aadharNumber;
  final String contactNumber;

  const RequestProfilePage(
      {Key key,
      this.role,
      this.userName,
      this.emailID,
      this.grade,
      this.division,
      this.aadharNumber,
      this.contactNumber,
      this.profilePicture})
      : super(key: key);
  @override
  _RequestProfilePageState createState() => _RequestProfilePageState();
}

class _RequestProfilePageState extends State<RequestProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.role.toUpperCase()} details'),
        iconTheme: IconThemeData(
          color: teal2,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
//              Padding(
//                padding: const EdgeInsets.only(bottom: 20.0),
//                child: Center(
//                  child: CircularProfileAvatar(
//                    null,
//                    child: Hero(
//                      tag: "profile",
//                      child: User.userPhotoData == null
//                          ? Image.asset('images/userPhoto.jpg')
//                          : Image.memory(
//                              base64Decode(User.userPhotoData),
//                            ),
//                    ),
//                    borderColor: teal2,
//                    elevation: 5,
//                    radius: 22,
//                  ),
//                ),
//              ),
              buildFieldEntry(
                label: 'Name',
                value: widget.userName ?? "-",
              ),
              buildFieldEntry(
                label: 'Email ID',
                value: widget.emailID ?? "-",
              ),
              buildFieldEntry(
                label: 'Grade',
                value: widget.grade ?? "-",
              ),
              buildFieldEntry(
                label: 'Division',
                value: widget.division ?? "-",
              ),
              buildFieldEntry(
                label: 'Contact Number',
                value: widget.contactNumber.toString() ?? "-",
              ),
              buildFieldEntry(
                label: 'Aadhar Number',
                value: widget.aadharNumber.toString() ?? "-",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildFieldEntry({String label, String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 20, color: teal2),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                style: TextStyle(color: teal1),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: value,
                  hintStyle: TextStyle(color: teal1, fontSize: 18),
                ),
                readOnly: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
