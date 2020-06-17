import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEdit = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: teal2,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          _isEdit
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: MaterialButton(
                      minWidth: 80,
                      color: teal2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEdit = false;
                        });
                      }),
                )
              : IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: teal2,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEdit = !_isEdit;
                    });
                  })
        ],
        elevation: 0,
      ),
      drawer: buildDrawer(context),
      body: Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Center(
                  child: Hero(
                    tag: "profile",
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: User.userPhotoData == null
                          ? AssetImage('images/userPhoto.jpg')
                          : Image.memory(base64Decode(User.userPhotoData)),
                    ),
                  ),
                ),
              ),
              buildFieldEntry(
                label: 'Name',
                value: User.userName ?? "-",
              ),
              buildFieldEntry(
                label: 'Email ID',
                value: User.userEmail ?? "-",
              ),
              buildFieldEntry(
                label: 'Institute Name',
                value: User.instituteName ?? "-",
              ),
              buildFieldEntry(
                label: 'Institute Type',
                value: User.userInstituteType ?? "-",
              ),
              buildFieldEntry(
                label: 'State',
                value: User.state ?? "-",
              ),
              buildFieldEntry(
                label: 'City',
                value: User.city ?? "-",
              ),
              buildFieldEntry(
                label: 'Contact Number',
                value: User.contactNumber.toString() ?? "-",
              ),
              buildFieldEntry(
                label: 'Aadhar Number',
                value: User.aadharNumber.toString() ?? "-",
              ),
              buildFieldEntry(
                label: 'Mail Address',
                value: User.mailAddress ?? "-",
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
                    borderSide: _isEdit
                        ? BorderSide(width: 2, color: teal2)
                        : BorderSide.none,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: _isEdit
                        ? BorderSide(width: 1, color: teal2)
                        : BorderSide.none,
                  ),
                  hintText: value,
                  hintStyle: TextStyle(color: teal1, fontSize: 18),
                ),
                readOnly: !_isEdit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
