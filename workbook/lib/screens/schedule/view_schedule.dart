import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:workbook/constants.dart';
import 'package:http/http.dart' as http;

import '../../user.dart';

class ViewSchedule extends StatefulWidget {
  @override
  _ViewScheduleState createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  bool _exists = false;
  bool _isLoading = false;
  String imageUrl = '';
  Future _fetchUrl() async {
    var response = await http.post(
      "$baseUrl/admin/fetchSchedule",
      body: {
        "userID": User.userEmail,
        "jwtToken": User.userJwtToken,
        "grade": User.grade,
        "division": User.division,
        "instituteName": User.instituteName,
      },
    );
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (json.decode(response.body)['statusCode'] == 200) {
      setState(() {
        imageUrl = json.decode(response.body)['payload']['schedule'];
        _exists = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUrl();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: violet1,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Schedule',
            style: TextStyle(color: violet1, fontSize: 22),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16),
          child: !_exists
              ? Center(
                  child: Text(
                    'No Schedule Allotted',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                ),
        ),
      ),
    );
  }
}
